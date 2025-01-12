#ifndef UTIL_H
#define UTIL_H

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

/* socket comm routines */
int GetServerSocket(int from, int to, int *actual);
int GetClientSocket(int portno);
BOOL WriteString(int sock, char *str);
BOOL ReadString(int sock, char *str, size_t count);
char *ReadStringAnySize(int sock);

/* returns newly allocated string made from path by substituting "~"
   with getenv("HOME") */
char *ManglePath(const char *path);

/* returns newly allocated name of the defaults file constructed from
   GNUSTEP_USER_PATH and GNUSTEP_DEFAULTS_FILE, or ~/GNUstep/Defaults,
   if not present. */
char *MakeDefaultsFilename();

/* Tries to lock filename by creating a directory called
   "filename.lock"; if that exists, sleeps two seconds, then tries
   again. Returns NO if unsuccessful, YES otherwise. */
BOOL LockFile(char *filename);

/* Unlocks the file by removing the dir created by LockFile. */
BOOL UnlockFile(char *filename);

/* Returns YES if file is stat()-able, NO if it isn't */
BOOL StatDomain(char *filename, proplist_t key, struct stat *buf);

/* Removes the domain file from disk. Returns YES if successful, NO
   otherwise. */
BOOL DeleteDomain(char *filename, proplist_t key);

proplist_t ReadDomain(char *filename, proplist_t key);

void *MyMalloc(char *file, int line, size_t size);

void MyFree(char *file, int line, void *mem);
#endif /* UTIL_H */
