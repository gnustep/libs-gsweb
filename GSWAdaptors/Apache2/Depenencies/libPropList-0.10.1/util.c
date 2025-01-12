/* util.c:

   Miscellaneous stuff

   */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

#include <errno.h>

#include "proplist.h"

#include "plconf.h"

#include "util.h"

/*
 * handling sockets
 */

int GetServerSocket(int from, int to, int *actual)
{
  int sock;
  struct protoent *pent;
  char hostname[256];
  struct hostent *localhost;
  struct sockaddr_in saddr;
  int current;

  if(!(pent = getprotobyname("tcp")))
    return -1;
  
  if((sock = socket(AF_INET, SOCK_STREAM, pent->p_proto)) < 0)
    return -1;

  if((gethostname(hostname, 255)) < 0)
    return -1;

  if(!(localhost = gethostbyname(hostname)))
    return -1;

  *actual = 0;
  current = from;

  saddr.sin_family = AF_INET;
  bcopy((char *)localhost->h_addr, (char *)&(saddr.sin_addr),
	localhost->h_length);

  while(current <= to)
    {
      saddr.sin_port = htons(current);
  
      if((bind(sock, (struct sockaddr *)&saddr,
	       sizeof(struct sockaddr_in))) == 0)
	{
	  if((listen(sock, 5)) < 0)
	    return -1;
	  else
	    {
	      *actual = current;
	      return sock;
	    }
	}
      else /* bind() failed */
	current++;
    }
  /* gone through all allowed ports, still no bind */
  return -1;
}

int GetClientSocket(int portno)
{
  int sock;
  struct protoent *pent;
  char hostname[256];
  struct hostent *localhost;
  struct sockaddr_in saddr;

  if(!(pent = getprotobyname("tcp")))
    return -1;
  
  if((sock = socket(AF_INET, SOCK_STREAM, pent->p_proto)) < 0)
    return -1;

  if((gethostname(hostname, 255)) < 0)
    return -1;

  if(!(localhost = gethostbyname(hostname)))
    return -1;

  saddr.sin_family = AF_INET;
  saddr.sin_port = htons(portno);
  bcopy((char *)localhost->h_addr, (char *)&(saddr.sin_addr),
	localhost->h_length);

  if((connect(sock, (struct sockaddr *)&saddr,
	      sizeof(struct sockaddr_in))) < 0)
    return -1;

  return sock;
}
  
BOOL WriteString(int sock, char *str)
{
  int bytes, bytes_remaining;

  bytes_remaining = strlen(str);

  while(bytes_remaining)
    {
      bytes = write(sock, str, bytes_remaining);
      if(bytes<0)
	return NO;
      bytes_remaining -= bytes;
    }
  return YES;
}

BOOL ReadString(int sock, char *str, size_t count)
{
  int bytes;

  bytes = read(sock, str, count-1);
  if(bytes<=0)
    return NO;

  str[bytes] = '\0';
  return YES;
}

char *ReadStringAnySize(int sock)
{
  int bytes, cur_index, cur_length;
  char *str, *tmp;
  char c;

  cur_index=0;
  cur_length = 256;
  str = (char *)MyMalloc(__FILE__, __LINE__, cur_length);

  while((bytes = read(sock, &c, 1)))
    {
      if(bytes<0)
	{
	  MyFree(__FILE__, __LINE__, str);
	  return NULL;
	}

      if(c=='\n')
	{
	  str[cur_index] = '\0';
	  return str;
	}

      str[cur_index++]=c;

      if(cur_index==cur_length-1)
	{
	  cur_length+=256;
	  str[cur_index] = '\0';
	  tmp = (char *)MyMalloc(__FILE__, __LINE__, cur_length);
	  strcpy(tmp, str);
	  MyFree(__FILE__, __LINE__, str);
	  str = tmp;
	}
    }
  MyFree(__FILE__, __LINE__, str);
  return NULL;
}
      
char *ManglePath(const char *path)
{
  char *home;
  char *ret;

  if(!path) return 0;

  if(path[0] == '~')
    {
      home = getenv("HOME");
      ret = (char *)MyMalloc(__FILE__, __LINE__, strlen(home)+strlen(path)+1);
      sprintf(ret, "%s/%s", home, &(path[1]));
    }
  else
    {
      ret = (char *)MyMalloc(__FILE__, __LINE__, strlen(path)+1);
      strcpy(ret, path);
    }
  return ret;
}
      
char *MakeDefaultsFilename()
{
  char *env;
  char actual_filename[255];

  env = (char *)getenv("GNUSTEP_USER_PATH");
  if(!env)
    {
      env = (char *)getenv("HOME");
      if(!env) /* No HOME --- can this happen? */
	sprintf(actual_filename, "/GNUstep");
      else
	sprintf(actual_filename, "%s/GNUstep", env);
    }
  else
    sprintf(actual_filename, env);

  sprintf(&(actual_filename[strlen(actual_filename)]), "/");

  env = (char *)getenv("GNUSTEP_DEFAULTS_FILE");
  if(!env)
    sprintf(&(actual_filename[strlen(actual_filename)]), "Defaults");
  else
    sprintf(&(actual_filename[strlen(actual_filename)]), env);

  return ManglePath(actual_filename);
}

BOOL LockFile(char *name)
{
  char *lockfilename;

  lockfilename = MyMalloc(__FILE__, __LINE__, strlen(name)+6);
  sprintf(lockfilename, "%s.lock", name);

  if((mkdir(lockfilename, 0755)) < 0)
    {
      if(errno != EEXIST)
	{
	  MyFree(__FILE__, __LINE__, lockfilename);
	  return NO;
	}
      else
	{
	  sleep(2);
	  if((mkdir(lockfilename, 0755)) < 0)
	    {
	      MyFree(__FILE__, __LINE__, lockfilename);
	      return NO;
	    }
	}
    }
  MyFree(__FILE__, __LINE__, lockfilename);
  return YES;
}

BOOL UnlockFile(char *filename)
{
  char *lockfilename;
  
  lockfilename = MyMalloc(__FILE__, __LINE__, strlen(filename)+6);
  sprintf(lockfilename, "%s.lock", filename);
  
  if(rmdir(lockfilename) < 0)
    {
      MyFree(__FILE__, __LINE__, lockfilename);
      if(errno==ENOENT) return YES;
      else return NO;
    }

  MyFree(__FILE__, __LINE__, lockfilename);
  return YES;
}

BOOL StatDomain(char *filename, proplist_t key, struct stat *buf)
{
  char *actualFilename;

  actualFilename = MyMalloc(__FILE__, __LINE__, strlen(filename) +
			  strlen(PLGetString(key)) + 2);
  sprintf(actualFilename, "%s/%s", filename, PLGetString(key));

  if(stat(actualFilename, buf)<0)
    {
      MyFree(__FILE__, __LINE__, actualFilename);
      return NO;
    }
  MyFree(__FILE__, __LINE__, actualFilename);
  return YES;
}

BOOL DeleteDomain(char *filename, proplist_t key)
{
  char *actualFilename;

  actualFilename = MyMalloc(__FILE__, __LINE__, strlen(filename) +
			  strlen(PLGetString(key)) + 2);
  sprintf(actualFilename, "%s/%s", filename, PLGetString(key));

  if(unlink(actualFilename)<0)
    {
      MyFree(__FILE__, __LINE__, actualFilename);
      return NO;
    }
  MyFree(__FILE__, __LINE__, actualFilename);
  return YES;
}

proplist_t ReadDomain(char *filename, proplist_t key)
{
  char *actualFilename;
  proplist_t retval;
  
  actualFilename = MyMalloc(__FILE__, __LINE__, strlen(filename) +
			  strlen(PLGetString(key)) + 2);
  sprintf(actualFilename, "%s/%s", filename, PLGetString(key));

  retval = PLGetProplistWithPath(actualFilename);

  MyFree(__FILE__, __LINE__, actualFilename);
  return retval;
}

void *MyMalloc(char *file, int line, size_t size)
{
	void *retval = malloc(size);
#ifdef MEMDEBUG
	printf("Allocating %d bytes of memory at address 0x%x (%s:%d)\n", size, retval, file, line);
#endif
	return retval;
}

void MyFree(char *file, int line, void *mem)
{
#ifdef MEMDEBUG
	printf("Freeing memory at address 0x%x (%s:%d)\n", mem, file, line);
#endif
	free(mem);
}
