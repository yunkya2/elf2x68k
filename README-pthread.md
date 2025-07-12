# elf2x68k POSIX スレッドライブラリについて

## 概要

elf2x68k は Human68k v2.0 以降で追加されたバックグラウンドプロセス機能を用いてスレッド処理を行う、POSIX スレッドライブラリ libpthread を提供しています。Newlib環境でのみ使用できます。

## 動作環境

POSIX スレッドライブラリ (pthread) を利用するためには、Human68k の CONFIG.SYS で以下のように `PROCESS=` 行によってバックグラウンドプロセス機能が有効になっている必要があります。

例:
```
PROCESS = 8 10 10
```
(最大スレッド数 8、メインスレッドの優先度 10、タイムスライス 10ms という設定になります)

## 使用方法

POSIX スレッド (pthread) ライブラリは elf2x68k 配布ファイル内に libpthread.a として含まれています。  
POSIX スレッド API を用いたプログラムのリンクの際に `m68k-xelf-gcc` のコマンドラインに `-lpthread` オプションを追加することで使用できます。

例:
```
m68k-xelf-gcc -o threadtest.x threadtest.c -lpthread
```

## 提供 API

POSIX スレッドライブラリでは、POSIX スレッド API におおむね準拠した以下の API を用いることができます。

### ヘッダファイル

以下のヘッダファイルが使用できます。

  * <pthread.h>

### スレッド API

#### スレッド生成・終了
  * int **pthread_create**(pthread_t \**thread*, const pthread_attr_t \**attr*, void \*(*start_routine*)(void *), void \**arg*);
  * int **pthread_join**(pthread_t *thread*, void \*\**retval*);
  * int **pthread_detach**(pthread_t *thread*);
  * void **pthread_exit**(void \**retval*);
  * pthread_t **pthread_self**(void);
  * int **pthread_equal**(pthread_t *t1*, pthread_t *t2*);
  * void **pthread_yield**(void);
  * int **pthread_once**(pthread_once_t \**once_control*, void (*init_routine*)(void));

#### スレッドのキャンセル

  * int **pthread_cancel**(pthread_t *thread*);
  * int **pthread_setcancelstate**(int *state*, int \**oldstate*);
  * int **pthread_setcanceltype**(int *type*, int \**oldtype*);
  * void **pthread_testcancel**(void);

#### クリーンアップハンドラ

  * void **pthread_cleanup_push**(void (*routine*)(void *), void \**arg*);
  * void **pthread_cleanup_pop**(int *execute*);

#### スレッド属性

以下の関数は通常の POSIX スレッド API と同じ機能です。

  * int **pthread_attr_init**(pthread_attr_t \**attr*);
  * int **pthread_attr_destroy**(pthread_attr_t \**attr*);
  * int **pthread_attr_setdetachstate**(pthread_attr_t \**attr*, int *detachstate*);
  * int **pthread_attr_getdetachstate**(const pthread_attr_t \**attr*, int \**detachstate*);

以下の関数はスレッドのスケジューリングに関する属性を設定・取得します。

  * int **pthread_attr_setschedparam**(pthread_attr_t \**attr*, const struct sched_param \**param*);
  * int **pthread_attr_getschedparam**(const pthread_attr_t \**attr*, struct sched_param \**param*);
    * struct sched_param は以下のメンバを持つ構造体です。
      ```c
      struct sched_param {
          int sched_priority; // スレッドの優先度
      };
      ```
    * sched_priority には、スレッドに割り当てる CPU 時間の割合をメインスレッドに対する比率の逆数×0x100 で指定します。
      * デフォルト値は 0x0100 で、メインスレッドと同じ割合で CPU 時間が割り当てられます。
      * 値が小さいほど多くの CPU 時間が割り当てられます。例えば 0x0200 を指定するとメインスレッドの半分の CPU 時間が、 0x0080 を指定するとメインスレッドの倍の CPU 時間が割り当てられます。

以下の関数はスレッドのユーザスタック領域に関する属性を設定・取得します。デフォルトのユーザスタックサイズは 16KB です。

  * int **pthread_attr_setstack**(pthread_attr_t \**attr*, void \**stackaddr*, size_t *stacksize*);
  * int **pthread_attr_getstack**(const pthread_attr_t \**attr*, void \*\**stackaddr*, size_t \**stacksize*);
  * int **pthread_attr_setstacksize**(pthread_attr_t \**attr*, size_t *stacksize*);
  * int **pthread_attr_getstacksize**(const pthread_attr_t \**attr*, size_t \**stacksize*);

以下は POSIX 標準にない elf2x68k libpthread 独自の関数で、スレッドのスーパーバイザスタック領域に関する属性を設定・取得します。デフォルトのスーパーバイザスタックサイズは 8KB です。

  * int **pthread_attr_setsystemstack**(pthread_attr_t \**attr*, void \**stackaddr*, size_t *stacksize*);
  * int **pthread_attr_getsystemstack**(const pthread_attr_t \**attr*, void \*\**stackaddr*, size_t \**stacksize*);
  * int **pthread_attr_setsystemstacksize**(pthread_attr_t \**attr*, size_t *stacksize*);
  * int **pthread_attr_getsystemstacksize**(const pthread_attr_t \**attr*, size_t \**stacksize*);

#### ミューテックス (mutex)
  * int **pthread_mutex_init**(pthread_mutex_t \**mutex*, const pthread_mutexattr_t \**attr*);
  * int **pthread_mutex_destroy**(pthread_mutex_t \**mutex*);
  * int **pthread_mutex_lock**(pthread_mutex_t \**mutex*);
  * int **pthread_mutex_trylock**(pthread_mutex_t \**mutex*);
  * int **pthread_mutex_unlock**(pthread_mutex_t \**mutex*);

#### ミューテックス属性
  * int **pthread_mutexattr_init**(pthread_mutexattr_t \**attr*);
  * int **pthread_mutexattr_destroy**(pthread_mutexattr_t \**attr*);
  * int **pthread_mutexattr_settype**(pthread_mutexattr_t \**attr*, int *type*);
  * int **pthread_mutexattr_gettype**(const pthread_mutexattr_t \**attr*, int \**type*);
    * settype/gettype で設定する値は現在のところ意味を持ちません。

#### 条件変数 (condition variable)
  * int **pthread_cond_init**(pthread_cond_t \**cond*, const pthread_condattr_t \**attr*);
  * int **pthread_cond_destroy**(pthread_cond_t \**cond*);
  * int **pthread_cond_signal**(pthread_cond_t \**cond*);
  * int **pthread_cond_broadcast**(pthread_cond_t \**cond*);
  * int **pthread_cond_wait**(pthread_cond_t \**cond*, pthread_mutex_t \**mutex*);

#### 条件変数属性
  * int **pthread_condattr_init**(pthread_condattr_t \**attr*);
  * int **pthread_condattr_destroy**(pthread_condattr_t \**attr*);

#### バリア変数
  * int **pthread_barrier_init**(pthread_barrier_t \**barrier*, const pthread_barrierattr_t \**attr*, unsigned *count*);
  * int **pthread_barrier_destroy**(pthread_barrier_t \**barrier*);
  * int **pthread_barrier_wait**(pthread_barrier_t \**barrier*);

#### バリア変数属性
  * int **pthread_barrierattr_init**(pthread_barrierattr_t \**attr*);
  * int **pthread_barrierattr_destroy**(pthread_barrierattr_t \**attr*);

#### スピンロック
  * int **pthread_spin_init**(pthread_spinlock_t \**lock*, int *pshared*);
  * int **pthread_spin_destroy**(pthread_spinlock_t \**lock*);
  * int **pthread_spin_lock**(pthread_spinlock_t \**lock*);
  * int **pthread_spin_trylock**(pthread_spinlock_t \**lock*);
  * int **pthread_spin_unlock**(pthread_spinlock_t \**lock*);

#### 読み取り書き込みロック
  * int **pthread_rwlock_init**(pthread_rwlock_t \**rwlock*, const pthread_rwlockattr_t \**attr*);
  * int **pthread_rwlock_destroy**(pthread_rwlock_t \**rwlock*);
  * int **pthread_rwlock_rdlock**(pthread_rwlock_t \**rwlock*);
  * int **pthread_rwlock_tryrdlock**(pthread_rwlock_t \**rwlock*);
  * int **pthread_rwlock_wrlock**(pthread_rwlock_t \**rwlock*);
  * int **pthread_rwlock_trywrlock**(pthread_rwlock_t \**rwlock*);
  * int **pthread_rwlock_unlock**(pthread_rwlock_t \**rwlock*);

#### 読み取り書き込みロック属性
  * int **pthread_rwlockattr_init**(pthread_rwlockattr_t \**attr*);
  * int **pthread_rwlockattr_destroy**(pthread_rwlockattr_t \**attr*);

#### スレッド固有データ
  * int **pthread_key_create**(pthread_key_t \**key*, void(*destructor*)(void *));
  * int **pthread_key_delete**(pthread_key_t *key*);
  * int **pthread_setspecific**(pthread_key_t *key*, const void \**value*);
  * void \***pthread_getspecific**(pthread_key_t *key*);

## 仕様と制約事項

* CONFIG.SYS に `PROCESS=` 行がなくてバックグラウンド機能が有効になっていない場合、libpthread の関数は ENOSYS (システムコールがサポートされていない) エラーを返します。
* libpthread によって生成したスレッドは、そのプログラムを終了する際に削除されます。この処理のため、pthread_create() を初めて呼び出す際にそのプロセスの終了/CTRL+C/エラー時の処理アドレス(DOS _EXITVC/_CTRLCVC/_ERRJVC)を変更します。プログラムの方でこれらのベクタを上書きするとプログラム終了後にスレッドが残ったままになってしまうため、ベクタを変更する際は処理後に変更前のベクタアドレスに戻るようにしてください。
