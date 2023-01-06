/*
 *  fileio - a simple file I/O sample
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

__attribute__((constructor))
void ctor(void)
{
	printf("constructor\n");
}

__attribute__((destructor))
void dtor(void)
{
	printf("destructor\n");
}

int main(int argc, char **argv)
{
  FILE *fp;
  int size;
  int i;
  int x;
  char line[100];

  printf("file I/O test\r\n");

  fp = fopen("fileio.x", "r");
  fseek(fp, 0, SEEK_END);
  size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  printf("fileio.x size = %dbytes\r\n", size);
  fclose(fp);

  fp = fopen("testfile", "w");
  for (i = 0; i < 3; i++) {
    fprintf(fp, "line %d\n", i);
  }
  fclose(fp);

  fp = fopen("testfile2", "wb");
  for (i = 0; i < 3; i++) {
    fprintf(fp, "line %d\n", i);
  }
  fclose(fp);

  printf("read text mode file\n");
  fp = fopen("testfile", "r");
  while (fgets(line, sizeof(line), fp) != NULL) {
    for (x = 0; x < strlen(line); x++)
      printf("0x%02x ", line[x]);
    printf("\n");
  }
  fclose(fp);

  printf("read text mode file with binary mode\n");
  fp = fopen("testfile", "rb");
  while (fgets(line, sizeof(line), fp) != NULL) {
    for (x = 0; x < strlen(line); x++)
      printf("0x%02x ", line[x]);
    printf("\n");
  }
  fclose(fp);

  printf("read binary mode file with binary mode\n");
  fp = fopen("testfile2", "rb");
  while (fgets(line, sizeof(line), fp) != NULL) {
    for (x = 0; x < strlen(line); x++)
      printf("0x%02x ", line[x]);
    printf("\n");
  }
  fclose(fp);

  unlink("testfile");
  unlink("testfile2");

  printf("end\r\n");

  return 0;
}
