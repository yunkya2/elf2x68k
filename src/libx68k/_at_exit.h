#ifndef __AT_EXIT_H_
#define __AT_EXIT_H_

#define AT_EXIT_MAX             4

#define AT_EXIT_TYPE_EXITVC     0xfff0
#define AT_EXIT_TYPE_CTRLVC     0xfff1
#define AT_EXIT_TYPE_ERRJVC     0xfff2

int __at_exit(void (*func)(int));
void __at_exit_call(int);
void __at_exit_init(void);

#endif /* __AT_EXIT_H_ */
