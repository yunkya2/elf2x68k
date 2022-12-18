/*
 *  hellox - a simple Human68k sample without C libraries
 */

#define ioctl(num)          __asm__ volatile ("movel %0,%%d0; trap #15" :: "i"(num) : "%%d0")
#define ioctl_d1(num,d1)    __asm__ volatile ("movel %1,%%d1; movel %0,%%d0; trap #15" :: "i"(num), "d"(d1) : "%%d0", "%%d1")
#define ioctl_a1(num,a1)    __asm__ volatile ("movel %1,%%a1; movel %0,%%d0; trap #15" :: "i"(num), "a"(a1) : "%%d0", "%%a1")

#define dos_print(str)       __asm__ volatile ("movel %0,-(%%sp);.hword 0xff09; addql #4,%%sp" :: "a"(str) : "%%d0")
#define dos_exit()           __asm__ volatile (".hword 0xff00");

const char *msg[] = {
  "Hello, world\r\n",
  "X68000 test\r\n",
  "Test program\r\n",
};

void _start()
{
  int i;

  static short param[] = {0, 0, 255, 255, 0xff00, 0xffff};

  ioctl_d1(0x10, 0xe);
  ioctl(0x90);

  for (i = 0; i < 3; i++) {
    dos_print(msg[i]);
  }

  for (i = 0; i < 256; i++) {
    param[0] = i;
    param[2] = 255 - i;
    param[4] = i | (i << 8);
    ioctl_a1(0xb8, param);
  }

  dos_exit();
}
