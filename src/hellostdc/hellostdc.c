#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int main(int argc, char **argv)
{
  FILE *fp;
  int size;

  printf("stdc test\r\n");

  fp = fopen("hellostdc.x", "r");
  fseek(fp, 0, SEEK_END);
  size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  printf("size = %d\r\n", size);
  fclose(fp);

  printf("end\r\n");

  return 0;
}
