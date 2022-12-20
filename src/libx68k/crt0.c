/*
 * C program start-up
 */

#include <unistd.h>

int main(int argc, char **argv);

void
_start(void)
{
  int res;

  res = main(0, 0);

  _exit(res);
}
