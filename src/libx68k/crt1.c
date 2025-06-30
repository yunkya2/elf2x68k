#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/unistd.h>
#include <x68k/dos.h>
#include <x68k/iocs.h>
#include "_at_exit.h"

/* From crt0 */
extern char *_ENV0;
extern struct dos_comline *_cmdline;
extern struct dos_psp *_PSP;

/* User main */
extern int main (int, char **, char **);

/* Internal */
int 	__argc;
char **	__argv;
struct iocs_time	__ontime;
uint32_t _vernum;

static void
setup_environ (void)
{
  int env_size;
  char *cp;
  int i;
  int count = 0;

  if ((int)_ENV0 == 0xffffffff) {
    _ENV0 = 0;
    env_size = 0;
  } else {
    env_size = *(int *) _ENV0;
    /* Determine vector size */
    for (i = 0, cp = _ENV0 + sizeof (int);  /* Skip env size */
         i <= env_size;
         i++, cp++)
    {
      if (*cp == '\0')
      {
        count++;
        if (cp[1] == '\0')
          break;
      }
    }
  }

  /* Vectorize env */
  environ = (char **) malloc ((count + 1) * sizeof (char *));

  for (i = 0, cp = _ENV0 + sizeof (int);
       i < count;
       i++)
  {
    env_size = strlen (cp) + 1;
    environ[i] = (char *) malloc (env_size);
    strcpy (environ[i], cp);

    cp += env_size;
  }

  environ[count] = 0;
}

static void
setup_arguments (void)
{
  /* TODO : Allow quoted arguments (ignoring inner space).
   * Also Hupair shell and TwentyOne together can build
   * arguments containing quote and space. We have to handle
   * this as well. */

  char *p;
  int len, count = 1;

  p = _cmdline->buffer;
  while (*p)
  {
    /* Skip spaces */
    while ((*p) && (*p == ' '))
      p++;

    if (*p)
      count++;

    /* To end of arg */
    while ((*p) && (*p != ' '))
      p++;
  }

  __argv = (char **) malloc ((count + 1) * sizeof (char *));
  
  len = _cmdline->len + strlen (_PSP->exe_path) + strlen (_PSP->exe_name) + 1;
  p = (char *) malloc (len);

  /* Set program name */
  strcpy (p, _PSP->exe_path);
  strcat (p, _PSP->exe_name);
  __argv[0] = p;
  p += strlen (p);
  *p++ = '\0';

  /* Copy original cmdline */
  strcpy(p, _cmdline->buffer);

  count = 1;
  while (*p)
  {
    /* All space to \0 */
    while ((*p) && (*p == ' '))
      *p++ = '\0';

    if (*p)
      __argv[count++] = p;

    /* To end of arg */
    while ((*p) && (*p != ' '))
      p++;
  }

  __argc = count;
  __argv[count] = 0;
}

void __INIT_SECTION__(void);
void __FINI_SECTION__(void);

__attribute__((weak)) void __at_exit_init (void) {}

void
__crt1_startup (void)
{
  __ontime = _iocs_ontime ();
  _vernum = _dos_vernum ();

  setup_environ ();
  setup_arguments ();

  __at_exit_init ();
  atexit(__FINI_SECTION__);
  __INIT_SECTION__();

  errno = 0;
  exit (main (__argc, __argv, environ));
}
