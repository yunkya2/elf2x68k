/*
 *  crt1.c - C runtime startup code for X68000
 */

#include "config.h"
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

__attribute__((__weak__, __noinline__)) void
__crt1_setup_environ (void)
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

#ifdef SUPPORT_HUPAIR   /* HUPAIR doesn't use TAB for separator */
#define isseparator(c)  ((c) == ' ')
#else
#define isseparator(c)  (((c) == ' ') || ((c) == '\t'))
#endif

static void
setup_arguments (void)
{
  char *p;
  int len, count = 1;

  p = _cmdline->buffer;
  while (*p)
  {
    /* Skip spaces */
    while ((*p) && isseparator(*p))
      p++;

    if (*p)
      count++;

    /* To end of arg */
    while ((*p) && !isseparator(*p)) {
      if (*p == '"' || *p == '\'') {
        /* Skip quote */
        char quote = *p;
        p++;

        /* Skip until next quote */
        while (*p && *p != quote)
          p++;

        if (*p)
          p++;
      } else {
        p++;
      }
    }
  }

  __argv = (char **) malloc ((count + 1) * sizeof (char *));

#ifdef SUPPORT_HUPAIR
  int ishupair = (strcmp((char *)_cmdline - 8, "#HUPAIR") == 0);
  if (ishupair) {
    len = strlen(_cmdline->buffer + strlen(_cmdline->buffer) + 1) + 1;
  } else {
#endif
    len = strlen (_PSP->exe_path) + strlen (_PSP->exe_name) + 1;
#ifdef SUPPORT_HUPAIR
  }
#endif
  len += strlen(_cmdline->buffer) + 1;
  p = (char *) malloc (len);

  /* Set program name */
#ifdef SUPPORT_HUPAIR
  if (ishupair) {
    strcpy (p, _cmdline->buffer + strlen(_cmdline->buffer) + 1);
  } else {
#endif
    strcpy (p, _PSP->exe_path);
    strcat (p, _PSP->exe_name);
#ifdef SUPPORT_HUPAIR
  }
#endif
  __argv[0] = p;
  p += strlen (p);
  *p++ = '\0';

  char *q = _cmdline->buffer;

  count = 1;
  while (*q)
  {
    /* Skip spaces */
    while ((*q) && isseparator(*q))
      q++;

    if (*q)
      __argv[count++] = p;

    /* To end of arg */
    while ((*q) && !isseparator(*q)) {
      if (*q == '"' || *q == '\'') {
        /* Skip quote */
        char quote = *q;
        q++;

        /* Skip until next quote */
        while (*q && *q != quote)
          *p++ = *q++;

        if (*q)
          q++;
      } else {
        *p++ = *q++;
      }
    }
    *p++ = '\0';
  }

  __argc = count;
  __argv[count] = 0;
}

void __INIT_SECTION__(void);
void __FINI_SECTION__(void);

__attribute__((__weak__)) void __at_exit_init (void) {}

void
#ifdef SUPPORT_HUPAIR
__crt1_startup_hupair (void)
#else
__crt1_startup (void)
#endif
{
  __ontime = _iocs_ontime ();

  __crt1_setup_environ ();
  setup_arguments ();

  void __dosinit(void);
  __dosinit();

  __at_exit_init ();
  atexit(__FINI_SECTION__);
  __INIT_SECTION__();

  errno = 0;
  exit (main (__argc, __argv, environ));
}
