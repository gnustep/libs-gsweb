/* daemon.c: This is -*- c -*-

   Implements the functions used in talking to the user-defaults daemon

   */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>

#include "proplist.h"
#include "plconf.h"
#include "util.h"

#define GIVEUP(x, y) { char buf[255]; \
                       fprintf(stderr, "libPropList: %s:\n", x); \
		       sprintf(buf, "libPropList: %s", y); \
                       perror(buf); \
		       fprintf(stderr, "libPropList: Giving up.\n"); \
		       exit(1); }

static int sock;
static pid_t mypid, childpid;
static plcallback_t cb;
static char password[255];

BOOL initialized = NO;

void sighandler(int sig)
{
#if 0
  signal(sig, sighandler);
#else
  /* in Linux, signals are reset to their default behaviour after raised.
   * Since it is quite common that libPL raises many HUPs quickly... */
  struct sigaction sig_action;
  
  sig_action.sa_handler = sighandler;
  sigemptyset(&sig_action.sa_mask);
  sigaction(SIGHUP, &sig_action, NULL);
  
#endif
  if(cb)
    (*cb)();
}

int start_daemon(void)
{
  char *daemonpath;

  daemonpath = ManglePath(DAEMON);
  
  if((childpid = fork()) < 0)
    return -1;

  if(childpid==0)
    {
      /* execute daemon */
      if(execvp(daemonpath, NULL) < 0)
	{
	  fprintf(stderr, "libPropList: Couldn't start daemon %s:\n", DAEMON);
	  perror("libPropList: start_daemon");
	  fprintf(stderr, "libPropList: Giving up.\n");
	  kill(mypid, SIGTERM);
	  exit(1);
	}
    }

  free(daemonpath);
  return 0;
}

void initialize(void)
{
  struct stat file_stat;
  FILE *pidfile;
  char *pidfilename;
  char buf[255];
  int portno;
  pid_t pid;
  int i;
  
  mypid = getpid();
  pidfilename = ManglePath(PIDFILE);

  if(stat(pidfilename, &file_stat) < 0) {
    if(start_daemon() < 0)
      {
	fprintf(stderr, "libPropList: Could not start daemon %s:\n", DAEMON);
	perror("libPropList: start_daemon");
	fprintf(stderr, "libPropList: Giving up.\n");
	exit(1);
      }
    else /* start_daemon succeeded */
      if(stat(pidfilename, &file_stat) < 0)
	{
	  i=0;
	  while(i<TIMEOUT)
	    {
	      sleep(1);
	      i++;
	      if(stat(pidfilename, &file_stat) == 0) /* success */
		goto gotit;
	    }
	  fprintf(stderr, "libPropList: Could not start daemon %s: Timeout. Giving up.\n", DAEMON);
	  kill(childpid, SIGTERM);
	  exit(1);
	}
  }
  
gotit:
  
  pidfile = fopen(pidfilename, "r");
  if(!pidfile)
    {
      GIVEUP("Could not open PID file.", "fopen");
      kill(childpid, SIGTERM);
      exit(1);
    }

  fscanf(pidfile, "%d %d %s", &pid, &portno, password);

  sock = GetClientSocket(portno);
  if(sock<0)
    GIVEUP("Couldn't initiate connection", "GetClientSocket");

  sprintf(buf, "auth %s\n", password);
  if(!(WriteString(sock, buf)))
    GIVEUP("Couldn't authorize myself!", "auth");
  
  initialized = YES;
  free(pidfilename);
}

proplist_t PLGetDomainNames()
{
  char *desc;
  proplist_t arr;
  
  if(!initialized) initialize();

  if(!(WriteString(sock, "list\n")))
    return NULL;

  if(!(desc = ReadStringAnySize(sock)))
    return NULL;

  arr = PLGetProplistWithDescription(desc);

  MyFree(__FILE__, __LINE__, desc);

  return arr;
}

proplist_t PLGetDomain(proplist_t name)
{
  char *desc, *str;
  proplist_t domain;

  if(!initialized) initialize();

  desc = PLGetDescription(name);
  str = (char *)MyMalloc(__FILE__, __LINE__, strlen(desc)+6);

  sprintf(str, "get %s\n", desc);

  MyFree(__FILE__, __LINE__, desc);
  
  if(!(WriteString(sock, str)))
    {
      MyFree(__FILE__, __LINE__, str);
      return NULL;
    }

  MyFree(__FILE__, __LINE__, str);

  if(!(desc = ReadStringAnySize(sock)))
    return NULL;

  if(!strcmp(desc, "nil"))
    {
      MyFree(__FILE__, __LINE__, desc);
      return NULL;
    }

  domain = PLGetProplistWithDescription(desc);

  MyFree(__FILE__, __LINE__, desc);

  return domain;
}

proplist_t PLSetDomain(proplist_t name, proplist_t value,
		       BOOL kickme) 
{
  char *name_desc, *value_desc;
  char *str;

  if(!initialized) initialize();
  
  name_desc = PLGetDescription(name);
  value_desc = PLGetDescription(value);
  str = (char *)MyMalloc(__FILE__, __LINE__, strlen(name_desc)+strlen(value_desc)+50);

  if(kickme)
    sprintf(str, "set %s %s\n", name_desc, value_desc);
      
  else
    sprintf(str, "set-nonotify %d %s %s\n", mypid, name_desc,
	    value_desc);

  MyFree(__FILE__, __LINE__, name_desc);
  MyFree(__FILE__, __LINE__, value_desc);

  if(!(WriteString(sock, str)))
    {
      MyFree(__FILE__, __LINE__, str);
      return NULL;
    }

  MyFree(__FILE__, __LINE__, str);

  return(value);
}

proplist_t PLDeleteDomain(proplist_t name, BOOL kickme)
{
  char *name_desc;
  char *str;

  if(!initialized) initialize();
  
  name_desc = PLGetDescription(name);
  str = (char *)MyMalloc(__FILE__, __LINE__, strlen(name_desc)+50);
  
  if(kickme)
    sprintf(str, "remove %s\n", name_desc);
      
  else
    sprintf(str, "remove-nonotify %d %s\n", mypid, name_desc);

  MyFree(__FILE__, __LINE__, name_desc);
  
  if(!(WriteString(sock, str)))
    {
      MyFree(__FILE__, __LINE__, str);
      return NULL;
    }

  MyFree(__FILE__, __LINE__, str);

  return name;
}

proplist_t PLRegister(proplist_t name, plcallback_t callback)
{
  char *str, *desc;
  
  if(!initialized) initialize();

  cb = callback;

  signal(SIGNAL, &sighandler);

  if(name)
    {
      desc = PLGetDescription(name);
      
      str = (char *)MyMalloc(__FILE__, __LINE__, strlen(desc)+50);
      sprintf(str, "register %d %s\n", mypid, desc);
      MyFree(__FILE__, __LINE__, desc);
    }
  else
    {
      str = (char *)MyMalloc(__FILE__, __LINE__, 50);
      sprintf(str, "register %d\n", mypid);
    }
  
  if(!(WriteString(sock, str)))
    {
      MyFree(__FILE__, __LINE__, str);
      return NULL;
    }

  MyFree(__FILE__, __LINE__, str);

  return(name);
}

proplist_t PLUnregister(proplist_t name)
{
  char *str, *desc;
  
  if(!initialized) initialize();

  signal(SIGNAL, &sighandler);

  if(name)
    {
      desc = PLGetDescription(name);
      
      str = (char *)MyMalloc(__FILE__, __LINE__, strlen(desc)+50);
      sprintf(str, "unregister %d %s\n", mypid, desc);
      MyFree(__FILE__, __LINE__, desc);
    }
  else
    {
      str = (char *)MyMalloc(__FILE__, __LINE__, 50);
      sprintf(str, "unregister %d\n", mypid);
      cb = NULL;
      signal(SIGNAL, SIG_DFL);
    }
  
  if(!(WriteString(sock, str)))
    {
      MyFree(__FILE__, __LINE__, str);
      return NULL;
    }

  MyFree(__FILE__, __LINE__, str);

  return(name);
}
