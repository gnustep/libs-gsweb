/* types.c: This is -*- c -*-

 This file contains routines for setting up the elementary
 (i.e. simple) types string and data. */

#include "proplistP.h"
#include "util.h"

proplist_t PLMakeString(unsigned char *bytes)
{
  plptr_t internal = MyMalloc(__FILE__, __LINE__, sizeof(plint_t));
  internal->type = PLSTRING;
  internal->filename = NULL;
  internal->container = NULL;
  internal->str.string = bytes;
  return (proplist_t)internal;
}

proplist_t PLMakeData(unsigned char *data, unsigned int length)
{
  plptr_t internal = MyMalloc(__FILE__, __LINE__, sizeof(plint_t));
  internal->type = PLDATA;
  internal->filename = NULL;
  internal->container = NULL;
  internal->data.data = data;
  internal->data.length = length;
  return (proplist_t)internal;
}

