/*
 *  hellox - a simple Human68k sample without C libraries
 */

#include <x68k/iocs.h>
#include <x68k/dos.h>

const char *msg[] = {
  "Hello, world\r\n",
  "X68000 test\r\n",
  "Test program\r\n",
};

void _start()
{
  int i;
  static struct iocs_lineptr param = {0, 0, 255, 255, 0xff00, 0xffff};

  _iocs_crtmod(0xe);
  _iocs_g_clr_on();

  for (i = 0; i < 3; i++) {
    _dos_print(msg[i]);
  }

  for (i = 0; i < 256; i++) {
    param.x1 = i;
    param.x2 = 255 - i;
    param.color = i | (i << 8);
    _iocs_line(&param);
  }

  _dos_exit();
}
