/*
 *  hello - a simple Human68k sample
 */

#include <x68k/iocs.h>
#include <stdio.h>

const char *msg[] = {
  "Hello, world",
  "X68000 test",
  "Test program",
};

int main()
{
  int i;
  static struct iocs_lineptr param = {0, 0, 255, 255, 0xff00, 0xffff};

  _iocs_crtmod(0xe);
  _iocs_g_clr_on();

  for (i = 0; i < 3; i++) {
    printf("msg %d: %s\n", i, msg[i]); 
  }

  for (i = 0; i < 256; i++) {
    param.x1 = i;
    param.x2 = 255 - i;
    param.color = i | (i << 8);
    _iocs_line(&param);
  }
}
