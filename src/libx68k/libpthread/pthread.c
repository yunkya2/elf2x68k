/*
 *  pthread_create()
 *  pthread_exit()
 *  pthread_join()
 */

#include <stdio.h>
#include "pthread_internal.h"
#include "_at_exit.h"

//****************************************************************************
// Internal variables
//****************************************************************************

static pthread_internal_t main_pi;          // メインスレッドのスレッド内部情報 (メインスレッドを待ちに入れる際に使用)
static pthread_internal_t *threads = NULL;  // これまで生成したスレッド内部情報のリスト

static int terminate_tid;                   // pthread_exit()で終了するスレッドのID
static void *terminate_oldvect;             // 終了のために使用するDOS _CHANGE_PRの旧ベクタ

//****************************************************************************
// Internal functions
//****************************************************************************

/* 指定したIDのthreadを削除する */
static void _pthread_delete(pthread_t thread)
{
    // スレッド管理情報のアドレスを得る
    struct dos_prcptr *prc = (struct dos_prcptr *)(*(int *)0x1c50 + thread * 0x7c);

    // スレッドを未使用状態にする (DOS _KILL_PRの内部処理と同じ)
    prc->wait_flg = prc->counter = prc->max_counter = prc->doscmd = -1;
    prc->wait_time = 0;
    prc->psp_id = 0;
    prc->buf_ptr = NULL;

    // 現在のスレッド数を減らす
    (*(uint16_t  *)0x1c5a)--;

    // スレッド内部情報リストから削除する
    for (pthread_internal_t **ths = &threads; *ths != NULL; ths = &((*ths)->next)) {
        if ((*ths)->tid == thread) {
            pthread_internal_t *freepi = *ths;
            *ths = (*ths)->next;
            free(freepi);
            break;
        }
    }
}

/* 自分自身のスレッド終了処理(DOS _CHANGE_PRで他スレッドに切り替わった後に呼ばれる) */
static void _pthread_terminate(void)
{
    _pthread_delete(terminate_tid);
    _dos_intvcs(0xffff, terminate_oldvect);
}

/* プロセスが終了する際に生成したスレッドをすべて削除する */
static void pthread_at_exit(int type)
{
    pthread_internal_t *pi = __pthread_self_internal();
    int ssp = _pthread_enter_critical();
    if (pi != &main_pi) {
        // 停止するのがメインスレッドでない場合
        if (type == AT_EXIT_TYPE_EXITVC) {
            // 正常終了の場合、単に自分自身を終了させる
            terminate_tid = pi->tid;
            terminate_oldvect = _dos_intvcs(0xffff, _pthread_terminate);
        } else  {
            // CTRL+Cまたはエラー終了の場合、保存されているメインスレッドのPCを
            // DOS _CTRLVCまたは_ERRJVCの処理アドレスに差し替え後、
            // 実行権を放棄することでスレッド削除処理をメインスレッドに実行させる
            struct dos_prcptr *prc = (struct dos_prcptr *)(*(int *)0x1c50 + main_pi.tid * 0x7c);
            prc->pc_reg = (unsigned int)_dos_intvcg(type);
        } 
        // 終了処理が行われるまで待つ
        while (1) {
            _dos_change_pr();
        }
    } else {
        // 停止するのがメインスレッドなら全ての子スレッドを削除
        while (threads != NULL) {
            _pthread_delete(threads->tid);
        }
    }
    _pthread_leave_critical(ssp);
}

/* pthread APIの初期化 (プロセス終了時に実行するハンドラを登録) */
static void pthread_api_init(void)
{
    static int at_exit_registered = 0;

    if (at_exit_registered) {
        return;
    }
    at_exit_registered = 1;
    __at_exit(pthread_at_exit);

    // メインスレッドの内部情報を初期化
    struct dos_prcptr prc;
    main_pi.magic = PTH_MAGIC;
    main_pi.tid = _dos_get_pr(-2, &prc);
    main_pi.priority = prc.max_counter;
}

/* スレッドのエントリポイント */
static void _pthread_start(void)
{
    pthread_internal_t *pi = __pthread_self_internal();
    if (pi->start_routine) {
        pthread_exit(pi->start_routine(pi->arg));
    } else {
        pthread_exit((void *)-1);
    }
}

//****************************************************************************
// External functions (pthread internal)
//****************************************************************************

/* 現在実行中のスレッドの内部情報を取得する */
pthread_internal_t *__pthread_self_internal(void)
{
    struct dos_prcptr prc;
    int tid = _dos_get_pr(-2, &prc);
    if (tid == main_pi.tid) {
        return &main_pi;
    } else if (tid < 0) {
        return NULL;
    }
    return (pthread_internal_t *)prc.buf_ptr;
}

/* 指定したスレッドの内部情報を取得する (メインスレッドならNULL) */
pthread_internal_t *__pthread_tid_internal(pthread_t thread)
{
    struct dos_prcptr prc;
    if (thread == main_pi.tid || _dos_get_pr(thread, &prc) < 0) {
        return NULL;
    }
    return (pthread_internal_t *)prc.buf_ptr;
}

/* 機能を使用しない場合に呼ばれるクリーンアップハンドラ */
__attribute__((weak)) void __pthread_key_call_destructors(pthread_internal_t *pi) {}
__attribute__((weak)) void __pthread_call_all_cleanup(pthread_internal_t *pi) {}

//****************************************************************************
// External functions
//****************************************************************************

int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine)(void *), void *arg)
{
    pthread_internal_t *pi;
    uint32_t count = _dos_time_pr();

    if (count == 0xffffffff) {
        return ENOSYS;      // スレッドが有効になっていない
    }

    pthread_api_init();

    size_t allocsize = sizeof(pthread_internal_t);
    if (attr && attr->is_initialized) {
        // pthread_attr_tでスタックアドレスの指定がない場合は指定サイズで確保する
        if (attr->stackaddr == NULL) {
            allocsize += attr->stacksize;
        }
        if (attr->systemstackaddr == NULL) {
            allocsize += attr->systemstacksize;
        }
    } else {
        // pthread_attr_tでの指定がないのでデフォルトサイズで確保する
        allocsize += PTH_DEFAULT_USERSTACKSIZE + PTH_DEFAULT_SYSTEMSTACKSIZE;
    }

    // スレッドの内部情報とスタック領域を確保
    pi = (pthread_internal_t *)calloc(1, allocsize);
    if (pi == NULL) {
        return ENOMEM;
    }

    // スレッドの内部情報を初期化
    pi->magic = PTH_MAGIC;
    pi->stat = 0;
    pi->next = NULL;
    pi->waitnext = NULL;
    pi->start_routine = start_routine;
    pi->arg = arg;
    pi->retval = NULL;

    pi->priority = PTH_DEFAULT_PRIORITY;
    pi->userstacksize = PTH_DEFAULT_USERSTACKSIZE;
    pi->systemstacksize = PTH_DEFAULT_SYSTEMSTACKSIZE;
    pi->userstackaddr = pi->stack;
    pi->systemstackaddr = &pi->stack[pi->userstacksize];

    if (attr && attr->is_initialized) {
        // 属性が指定されている場合はそれに従う
        if (attr->detachstate == PTHREAD_CREATE_DETACHED) {
            pi->stat |= PTH_STAT_DETACHED;  // デタッチ状態にする
        }
        pi->priority = attr->priority;
        pi->userstacksize = attr->stacksize;
        pi->systemstacksize = attr->systemstacksize;
        if (attr->stackaddr != NULL) {
            pi->userstackaddr = attr->stackaddr;
            if (attr->systemstackaddr != NULL) {    // user,systemとも指定されている
                pi->systemstackaddr = attr->systemstackaddr;
            } else {                                // userのみ指定されている
                pi->systemstackaddr = pi->stack;
            }
        } else {
            if (attr->systemstackaddr != NULL) {    // systemのみ指定されている
                pi->systemstackaddr = attr->systemstackaddr;
            } else {                                // user,systemとも指定されていない
                pi->userstackaddr = pi->stack;
                pi->systemstackaddr = &pi->stack[pi->userstacksize];
            }
        }
    }

    // タスク間通信バッファを初期化
    pi->com.length = sizeof(pthread_internal_t) - sizeof(struct dos_prcctrl);
    pi->com.buf_ptr = (unsigned char *)&pi->magic;
    pi->com.your_id = -1;

    // スレッドを生成する
    int tid;
    int ssp = _pthread_enter_critical();
    while (1) {
        // 現在時刻からスレッド名を決めて生成する
        // (同名のスレッドが既に存在する場合は名前を変えて再試行)
        char name[16];
        snprintf(name, sizeof(name), "pthread%d", count++ % 100);

        tid = _dos_open_pr(name, (pi->priority * main_pi.priority >> 8) + 1,
                           (int)&((char *)pi->userstackaddr)[pi->userstacksize],
                           (int)&((char *)pi->systemstackaddr)[pi->systemstacksize],
                           0x0000, (int)_pthread_start, &pi->com, 0);
        if (tid > 0) {
            pi->next = threads; // 既存のスレッドリストの先頭に追加
            threads = pi;
            pi->tid = tid;      // スレッドIDを設定
            break;
        } else if (tid != -27) {
            _pthread_leave_critical(ssp);
            free(pi);
            return ENOMEM;     // これ以上スレッドを生成できない
        }
    }
    _pthread_leave_critical(ssp);

    *thread = (pthread_t)tid;

    // スレッドを起動する
    _dos_send_pr(0, tid, 0xfffb, NULL, 0);

    return 0;
}

void pthread_exit(void *retval)
{
    pthread_internal_t *pi = __pthread_self_internal();

    if (pi == NULL || pi == &main_pi) {
        exit((int)retval);
    }

    __pthread_key_call_destructors(pi);
    __pthread_call_all_cleanup(pi);

    pi->retval = retval;
    pi->stat |= PTH_STAT_TERMINATED;
    if (pi->stat & PTH_STAT_DETACHED) {
        // デタッチされている自分自身を終了する
        _pthread_enter_critical();
        terminate_tid = pi->tid;
        terminate_oldvect = _dos_intvcs(0xffff, _pthread_terminate);
        while (1) {
            _dos_change_pr();
        }
    } else {
        // 他のスレッドがjoinするまでスリープする
        while (1) {
            _dos_sleep_pr(0);
        }
    }
}

int pthread_join(pthread_t thread, void **retval)
{
    pthread_internal_t *pi = __pthread_tid_internal(thread);
    pthread_internal_t *mypi = __pthread_self_internal();

    __pthread_testcancel(mypi);

    if (pi == NULL || mypi == NULL) {
        return ESRCH;
    }

    if (pi->stat & PTH_STAT_DETACHED) {
        return EINVAL;  // スレッドはデタッチされているためjoinできない
    }

    mypi->stat |= PTH_STAT_IN_CANCEL_POINT; // キャンセルポイントに入る

    // スレッドが終了するまたはキャンセルされるまで待つ
    while (!(pi->stat & (PTH_STAT_TERMINATED|PTH_STAT_CANCELED))) {
        _dos_change_pr();
    }

    mypi->stat &= ~PTH_STAT_IN_CANCEL_POINT; // キャンセルポイントを出る

    // スレッドの戻り値を取得する
    if (retval) {
        if (pi->stat & PTH_STAT_CANCELED) {
            *retval = PTHREAD_CANCELED;     // スレッドがキャンセルされた場合
        } else {
            *retval = pi->retval;           // スレッドが正常に終了した場合
        }
    }

    // スレッドを削除する
    int ssp = _pthread_enter_critical();
    _pthread_delete(thread);
    _pthread_leave_critical(ssp);

    return 0;
}
