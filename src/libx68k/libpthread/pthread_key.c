/*
 *  pthread_key_create()
 *  pthread_key_delete()
 *  pthread_key_setspecific()
 *  pthread_key_getspecific()
 */

#include "pthread_internal.h"

//****************************************************************************
// Internal variables
//****************************************************************************

static void (*key_destructors[PTHREAD_KEYS_MAX])(void *);   // キーのデストラクタ配列
static int key_used_bitmap;                                 // 使用中のキーを示すビットマップ

//****************************************************************************
// External functions
//****************************************************************************

void __pthread_key_call_destructors(pthread_internal_t *pi)
{
    if (pi == NULL) {
        return;
    }

    int called;
    do  {
        called = 0;
        for (int i = 0; i < PTHREAD_KEYS_MAX; i++) {
            void *data = pi->specific_data[i];
            pi->specific_data[i] = NULL;
            if (data != NULL && key_destructors[i] != NULL) {
                key_destructors[i](data);
                called = 1;
            }
        }
    } while (called);
}

int pthread_key_create(pthread_key_t *key, void (*destructor)(void *))
{
    if (key == NULL) {
        return EINVAL;  // Invalid key pointer
    }

    int i;
    for (i = 0; i < PTHREAD_KEYS_MAX; i++) {
        // 使用中のキーを探す
        if (!(key_used_bitmap & (1 << i))) {
            key_used_bitmap |= (1 << i);  // キーを使用中に設定
            break;
        }
    }
    if (i == PTHREAD_KEYS_MAX) {
        return EAGAIN;  // すでに最大数のキーが使用中
    }

    key_destructors[i] = destructor;  // デストラクタを設定

    *key = (pthread_key_t)(i + 1);
    return 0;
}

int pthread_key_delete(pthread_key_t key)
{
    key--;
    if (key > PTHREAD_KEYS_MAX) {
        return EINVAL;  // Invalid key
    }
    if (!(key_used_bitmap & (1 << key))) {
        return EINVAL;  // Key not in use
    }
    key_used_bitmap &= ~(1 << key);  // キーを未使用に設定
    key_destructors[key] = NULL;  // デストラクタをクリア
    return 0;
}

int pthread_setspecific(pthread_key_t key, const void *value)
{
    key--;
    if (key > PTHREAD_KEYS_MAX) {
        return EINVAL;  // Invalid key
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return ESRCH;  // Current thread not found
    }
    if (pi->specific_data[key] != NULL && key_destructors[key] != NULL) {
        // 既存の値がある場合、デストラクタを呼び出す
        key_destructors[key](pi->specific_data[key]);
    }
    pi->specific_data[key] = (void *)value;  // スレッド固有データを設定
    return 0;
}

void *pthread_getspecific(pthread_key_t key)
{
    key--;
    if (key > PTHREAD_KEYS_MAX) {
        return NULL;  // Invalid key
    }

    pthread_internal_t *pi = __pthread_self_internal();
    if (pi == NULL) {
        return NULL;  // Current thread not found
    }
    return pi->specific_data[key];  // スレッド固有データを取得
}
