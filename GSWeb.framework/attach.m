/*************************************************************************
 *
 * $Id$
 *
 * Copyright (c) 1999 by Bjorn Reese <breese@mail1.stofanet.dk>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE AUTHORS AND
 * CONTRIBUTORS ACCEPT NO RESPONSIBILITY IN ANY CONCEIVABLE MANNER.
 *
 ************************************************************************/

#if defined(unix) || defined(__unix) || defined(__xlC__)
# define PLATFORM_UNIX
#elif defined(WIN32) || defined(_WIN32)
# define PLATFORM_WIN32
#endif

#include <assert.h>
#include <stdio.h>
#if defined(PLATFORM_WIN32)
/* Not implemented yet */
#else
# include <unistd.h>
# include <signal.h>
# include <fcntl.h>
# include <sys/types.h>
# include <sys/wait.h>
# include <string.h>
#endif


/*************************************************************************
 * Globals
 */

/* The name of the executable is needed by the debugger */
static char *global_processname = NULL;
/* Enable/disable all breakpoints */
static int global_breakpoints = 1;

#if !defined(PLATFORM_WIN32)
# if !defined(NDEBUG)

/*************************************************************************
 * my_special_system
 *
 * This works like system() except the parent process is forced to wait
 * until the debugger which is launched in the child process has been
 * attached to the parent process. This functions should only be used by
 * DebugAttacher().
 */
static int my_special_system(const char *command)
{
  int rc = 0;
  pid_t pid;
  volatile int attached = 0;
  
  pid = fork();
  switch (pid)
    {
    case -1: /* fork() failed */
      rc = 1;
      break;
	  
    case 0: /* Child */
      /*
       * The system() call assumes that /bin/sh is
       * always available, and so will we.
       */
      execl("/bin/sh", "/bin/sh", "-c", command, NULL);
      _exit(1);
      break;
	  
    default: /* Parent */
      /* Wait until the debugger is attached */
      /* It would be nicer to sleep() here, but it doesn't
       * appear to work on all platforms */
      while (!attached);
      break;
    } /* switch */
  return rc;
}

/*************************************************************************
 * DebugAttacher
 *
 * Do only use async-safe functions because DebugAttacher is called from
 * a signal handler.
 *
 * Note: sprintf() is not guaranteed to be async-safe, but in practice
 * it usually is. If this should pose a problem, the <string.h> functions
 * could be used instead.
 */
static void DebugAttacher(int sig)
{
  char buffer[512];
  char filename[64];
  int fd;

  /* Prevent race conditions */
  signal(sig, SIG_DFL);

  /* Write the initial debugging commands to a temporary file */
  sprintf(filename, "/tmp/_attach_%d_", (int)getpid());
  fd = open(filename, O_WRONLY | O_CREAT, 0700);
  if (fd != -1) {
    /* These commands assume gdb */
    sprintf(buffer,
	    "set height 0\n"
	    "set attached = 1\n"
	    "finish\n" /* my_special_system() */
	    "finish\n" /* DebugAttacher() */
	    "finish\n" /* signal handler */
	    "finish\n" /* raise() */
	    "finish\n" /* DebugBreakpoint() */);
    write(fd, buffer, strlen(buffer));
    close(fd);

    /* Launch the debugger */
    sprintf(buffer, "xterm -e gdb -x %s %s %d",
	    filename,
	    global_processname,
	    (int)getpid());
    my_special_system(buffer);

    /* Remove the temporary file */
    unlink(filename);
  }
}

/*************************************************************************
 */
static void DebugInstallAttacher(char *processname)
{
  struct sigaction sact;

  global_processname = processname;
  
  sigemptyset(&sact.sa_mask);
  sact.sa_flags = 0;
  sact.sa_handler = DebugAttacher;
  sigaction(SIGTRAP, &sact, NULL);
}

static void DebugUninstallAttacher(void)
{
  signal(SIGTRAP, SIG_DFL);
}

# endif /* !defined(NDEBUG) */
#endif /* !defined(PLATFORM_WIN32) */

/*************************************************************************
 */
void DebugInstall(char *processname)
{
  assert(processname != NULL);
  
#if !defined(NDEBUG) && !defined(PLATFORM_WIN32)
  DebugInstallAttacher(processname);
#endif
}

/*************************************************************************
 */
void DebugUninstall(void)
{
#if !defined(NDEBUG) && !defined(PLATFORM_WIN32)
  DebugUninstallAttacher();
#endif
}

/*************************************************************************
 */
void DebugBreakpoint(void)
{
#if !defined(NDEBUG)
# if !defined(PLATFORM_WIN32)
  if (global_breakpoints)
    raise(SIGTRAP);
# endif
#endif
}

/*************************************************************************
 */
void DebugEnableBreakpoints(void)
{
  global_breakpoints = 1;
}

/*************************************************************************
 */
void DebugDisableBreakpoints(void)
{
  global_breakpoints = 0;
}


#if defined(STANDALONE)
int main(int argc, char *argv[])
{
  DebugInstall(argv[0]);
  DebugEnableBreakpoints();
  
  DebugBreakpoint();
  return 0;
}
#endif
