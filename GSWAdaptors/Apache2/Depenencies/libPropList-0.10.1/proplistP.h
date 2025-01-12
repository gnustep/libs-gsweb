/* proplistP.h: This is -*- c -*-

   This file contains private definitions for libPropList. DO NOT USE
   THEM YOURSELF! proplist.h should have all that you need.

   */

#ifndef PROPLISTP_H
#define PROPLISTP_H

#include "proplist.h"

typedef struct {
  char *string;
} plString;

typedef struct {
  unsigned char *data;
  unsigned int length;
} plData;

typedef struct {
  proplist_t *elements;
  unsigned int number;
} plArray;

typedef struct {
  proplist_t *keys;  
  proplist_t *values;
  unsigned int number;
} plDictionary;

typedef struct
{
  unsigned char type;
  proplist_t filename;
  proplist_t container;
  BOOL changed;
  unsigned long retain_count;
  union {
    plString str;
    plData data;
    plArray array;
    plDictionary dict;
  } t;
} plint_t, *plptr_t;

#define PLSTRING     0
#define PLDATA       1
#define PLARRAY      2
#define PLDICTIONARY 3

#endif /* !def PROPLISTP_H */


