/* memhandling.c: This is -*- c -*-

 This file contains destroying / copying / retaining functions.

 */

#include <stdlib.h>

/* for SunOS */
#ifndef NULL
#include <stddef.h>
#endif

#include "proplist.h"
#include "proplistP.h"
#include "util.h"

#ifdef DEBUG
unsigned long num_objects;
#endif


void PLRelease(proplist_t pl)
{
  plptr_t internal;
  int i;

  internal = (plptr_t)pl;
  internal->retain_count--;
#ifdef DEBUG
  num_objects--;
  printf("Releasing object %s\n", PLGetDescription(pl));
  printf("\t(count: %ld, num_objects: %ld)\n", internal->retain_count,
	 num_objects);
#endif

  switch(internal->type)
    {
    case PLSTRING:
      if(!internal->retain_count)
	{
	  if(internal->t.str.string)
	    MyFree(__FILE__, __LINE__, internal->t.str.string);
	  if(internal->filename)
	    PLRelease(internal->filename);
	  MyFree(__FILE__, __LINE__, pl);
	}
      break;
    case PLDATA:
      if(!internal->retain_count)
	{
	  if(internal->t.data.data)
	    MyFree(__FILE__, __LINE__, internal->t.data.data);
	  if(internal->filename)
	    PLRelease(internal->filename);
	  MyFree(__FILE__, __LINE__, pl);
	}
      break;
    case PLARRAY:
      for(i=0;i<internal->t.array.number;i++)
	PLRelease(internal->t.array.elements[i]);
      if(!internal->retain_count)
	{
	  if(internal->t.array.elements)
	    MyFree(__FILE__, __LINE__, internal->t.array.elements);
	  if(internal->filename)
	    PLRelease(internal->filename);
	  MyFree(__FILE__, __LINE__, pl);
	}
      break;
    case PLDICTIONARY:
      for(i=0;i<internal->t.dict.number;i++)
	{
	  PLRelease(internal->t.dict.keys[i]);
	  PLRelease(internal->t.dict.values[i]);
	}
      if(!internal->retain_count)
	{
	  if(internal->t.dict.keys)
	    MyFree(__FILE__, __LINE__, internal->t.dict.keys);
	  if(internal->t.dict.values)
	    MyFree(__FILE__, __LINE__, internal->t.dict.values);
	  if(internal->filename)
	    PLRelease(internal->filename);
	  MyFree(__FILE__, __LINE__, pl);
	}
      break;
    default:
      break;
    }
}

proplist_t PLShallowCopy(proplist_t pl)
{
  plptr_t internal;
  proplist_t ret;
  int i;
  proplist_t allkeys, key, value;
  
  internal = (plptr_t)pl;

  switch(internal->type)
    {
    case PLSTRING:
    case PLDATA:
      return PLDeepCopy(pl);
    case PLARRAY:
      ret = PLMakeArrayFromElements(NULL);
      for(i=0; i<PLGetNumberOfElements(pl); i++)
	PLAppendArrayElement(ret, PLGetArrayElement(pl, i));
      return ret;
    case PLDICTIONARY:
      ret = PLMakeDictionaryFromEntries(NULL, NULL);
      allkeys = PLGetAllDictionaryKeys(pl);
      for(i=0; i<PLGetNumberOfElements(allkeys); i++)
	{
	  key = PLGetArrayElement(allkeys, i);
	  value = PLGetDictionaryEntry(pl, key);
	  PLInsertDictionaryEntry(ret, key, value);
	}
      PLRelease(allkeys);
    default:
      return NULL;
    }
}

proplist_t PLDeepCopy(proplist_t pl)
{
  plptr_t internal;
  proplist_t ret;
  int i;

  internal = (plptr_t)pl;

  switch(internal->type)
    {
    case PLSTRING:
      ret = PLMakeString(internal->t.str.string);
      if(internal->filename)
	PLSetFilename(ret, internal->filename);
      return ret;
    case PLDATA:
      ret = PLMakeData(internal->t.data.data,
		       internal->t.data.length);
      if(internal->filename)
	PLSetFilename(ret, internal->filename);
      return ret;
    case PLARRAY:
      ret = PLMakeArrayFromElements(NULL);
      for(i=0;i<internal->t.array.number;i++)
	{
	  proplist_t el = PLDeepCopy(internal->t.array.elements[i]);
	  PLAppendArrayElement(ret, el);
/*	  PLRelease(el); */
	}
      if(internal->filename)
	PLSetFilename(ret, internal->filename);
      return ret;
    case PLDICTIONARY:
      ret = PLMakeDictionaryFromEntries(NULL, NULL);
      for(i=0;i<internal->t.dict.number;i++)
	{
	  proplist_t key, value;
	  key = PLDeepCopy(internal->t.dict.keys[i]);
	  value = PLDeepCopy(internal->t.dict.values[i]);
	  PLInsertDictionaryEntry(ret, key, value);
	  PLRelease(key); PLRelease(value);
	}
      if(internal->filename)
	PLSetFilename(ret, internal->filename);
      return ret;
    default:
      return NULL;
    }
}


proplist_t PLRetain(proplist_t pl)
{
  plptr_t internal = (plptr_t)pl;
  int i;

  internal->retain_count++;

#ifdef DEBUG
  num_objects++;
  printf("Retaining object %s\n", PLGetDescription(pl));
  printf("\t(count: %ld, num_objects: %ld)\n", internal->retain_count, num_objects);
#endif
  
  switch(internal->type)
    {
    case PLSTRING:
    case PLDATA:
      return pl;
    case PLARRAY:
      for(i=0; i<internal->t.array.number; i++)
	PLRetain(internal->t.array.elements[i]);
      return pl;
    case PLDICTIONARY:
      for(i=0; i<internal->t.dict.number; i++)
	{
	  PLRetain(internal->t.dict.keys[i]);
	  PLRetain(internal->t.dict.values[i]);
	}
      return pl;
    default:
      return NULL;
    }
}
