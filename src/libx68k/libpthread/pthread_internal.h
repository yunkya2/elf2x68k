#ifndef _PTHREAD_INTERNAL_H_
#define _PTHREAD_INTERNAL_H_

#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include "../../features.h"
#include <pthread.h>
#include <sys/types.h>
#include <x68k/dos.h>
#include <x68k/iocs.h>

#define PTH_DEFAULT_USERSTACKSIZE   (16 * 1024)
#define PTH_DEFAULT_SYSTEMSTACKSIZE (8 * 1024)
#define PTH_DEFAULT_PRIORITY        256

#define PTH_MAGIC                   0x50746831  // 'Pth1'

/* スレッド状態フラグ */
#define PTH_STAT_DETACHED           0x01    // スレッドはデタッチされている
#define PTH_STAT_WAITING            0x02    // スレッドは待機中
#define PTH_STAT_CANCEL_DISABLE     0x04    // スレッドはキャンセル不可能
#define PTH_STAT_CANCEL_ASYNC       0x08    // スレッドは非同期キャンセル可能
#define PTH_STAT_IN_CANCEL_POINT    0x10    // スレッドはキャンセルポイントにいる
#define PTH_STAT_DEFEREED_CANCELED  0x20    // スレッドは遅延キャンセルされている
#define PTH_STAT_CANCELED           0x40    // スレッドはキャンセルされている
#define PTH_STAT_TERMINATED         0x80    // スレッドは終了している

/* スレッド内部情報構造体 */
typedef struct pthread_internal {
    struct dos_prcctrl com;             // タスク間通信バッファ

    uint32_t magic;                     // 'Pth1'
    pthread_t tid;                      // スレッドID
    uint32_t stat;                      // スレッド状態 (PTH_STAT_*)

    struct pthread_internal *main_pi;   // メインスレッドのスレッド内部情報へのポインタ
    struct pthread_internal *next;      // 次のスレッド内部情報へのポインタ
    struct pthread_internal *waitnext;  // 同じ待ち状態の次のスレッドへのポインタ

    void *(*start_routine)(void *);     // スレッド開始関数
    void *arg;                          // スレッド開始関数の引数
    void *retval;                       // スレッド終了時の戻り値

    uint16_t priority;                  // スレッドの優先度 (0x0100 = メインスレッドと同じ)

    void *specific_data[PTHREAD_KEYS_MAX];      // スレッド固有データ
    struct _pthread_cleanup_context *cleanup;   // クリーンアップハンドラの登録リスト

    size_t userstacksize;               // ユーザースタックサイズ
    size_t systemstacksize;             // システムスタックサイズ
    void *userstackaddr;                // ユーザースタックのアドレス
    void *systemstackaddr;              // システムスタックのアドレス
    uint8_t stack[0];                   // ユーザー+システムスタック領域
} pthread_internal_t;

/* 内部用API */
pthread_internal_t *__pthread_self_internal(void);              // 現在実行中のスレッドの内部情報を取得する
pthread_internal_t *__pthread_tid_internal(pthread_t thread);   // 指定したスレッドの内部情報を取得する (メインスレッドならNULL)
void __pthread_testcancel(pthread_internal_t *pi);              // 指定したスレッドでキャンセルが保留中か確認する
void __pthread_call_all_cleanup(pthread_internal_t *pi);        // スレッドが終了する際にクリーンアップハンドラを呼ぶ
void __pthread_key_call_destructors(pthread_internal_t *pi);    // スレッドが終了する際にキーのデストラクタ関数を呼ぶ

/* クリティカルセクションに入る */
static inline int _pthread_enter_critical(void)
{
    int res;
    __asm__ volatile(
        "suba.l  %%a1,%%a1\n"
        "moveq.l #0xffffff81,%%d0\n" // IOCS _B_SUPER
        "trap    #15\n"
        "ori.w   #0x0700,%%sr\n"
        "move.l  %%d0,%0\n"
    : "=d"(res) : : "a1", "memory");
    return res;
}

/* クリティカルセクションから出る */
static inline void _pthread_leave_critical(int ssp)
{
    __asm__ volatile(
        "andi.w  #0xf8ff,%%sr\n"
        "tst.l   %0\n"      // 既にスーパーバイザモードだった際に_pthread_enter_critical()を
        "bmi     1f\n"      // 呼ぶと -1 を返されるので、その場合は何もしない
        "movea.l %0,%%a1\n"
        "move.l  %%sp,%%usp\n"
        "moveq.l #0xffffff81,%%d0\n" // IOCS _B_SUPER
        "trap    #15\n"
        "1:\n"
    : : "d"(ssp) : "d0", "a1", "memory");
}

#endif /* _PTHREAD_INTERNAL_H_ */
