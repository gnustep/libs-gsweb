/* comparing.c: This is -*- c -*-

   This file implements the PLIs... functions

   */

#include "proplistP.h"

/* forward prototype */
BOOL PLStrCmp(proplist_t pl1, proplist_t pl2);

BOOL (*plStrCmp)(proplist_t, proplist_t) = &PLStrCmp;

void PLSetStringCmpHook(BOOL(*fn)(proplist_t, proplist_t))
{
  if(!fn)
    plStrCmp = &PLStrCmp;
  else
    plStrCmp = fn;
}

BOOL PLStrCmp(proplist_t pl1, proplist_t pl2)
{
  plptr_t int1, int2;

  int1 = pl1; int2 = pl2;
  if(!strcmp(int1->t.str.string, int2->t.str.string))
    return YES;
  else
    return NO;
}

BOOL PLIsString(proplist_t pl)
{
  if(((plptr_t)pl)->type == PLSTRING)
    return YES;
  return NO;
}

BOOL PLIsData(proplist_t pl)
{
  if(((plptr_t)pl)->type == PLDATA)
    return YES;
  return NO;
}

BOOL PLIsArray(proplist_t pl)
{
  if(((plptr_t)pl)->type == PLARRAY)
    return YES;
  return NO;
}

BOOL PLIsDictionary(proplist_t pl)
{
  if(((plptr_t)pl)->type == PLDICTIONARY)
    return YES;
  return NO;
}

BOOL PLIsSimple(proplist_t pl)
{
  if(PLIsString(pl)||PLIsData(pl))
    return YES;
  return NO;
}

BOOL PLIsCompound(proplist_t pl)
{
  if(PLIsArray(pl)||PLIsDictionary(pl))
    return YES;
  return NO;
}

BOOL PLIsEqual(proplist_t pl1, proplist_t pl2)
{
  plptr_t int1, int2;
  int i;
  
  int1 = pl1; int2 = pl2;
  
  if((int1->type != int2->type))
    return NO;

  switch(int1->type)
    {
    case PLSTRING:
      return (*plStrCmp)(pl1, pl2);
    case PLDATA:
      if(int1->t.data.length != int2->t.data.length)
	return NO;
      if(memcmp(int1->t.data.data, int2->t.data.data, int1->t.data.length)!=0)
	return NO;
      return YES;
    case PLARRAY:
      if(int1->t.array.number != int2->t.array.number)
	return NO;
      for(i=0;i<int1->t.array.number;i++)
	if(!PLIsEqual(int1->t.array.elements[i],
		      int2->t.array.elements[i]))
	  return NO;
      return YES;
    case PLDICTIONARY:
      if(int1->t.dict.number != int2->t.dict.number)
	return NO;
      for(i=0;i<int1->t.dict.number;i++)
	if(!PLIsEqual(int1->t.dict.keys[i],
		      int2->t.dict.keys[i]) ||
	   !PLIsEqual(int1->t.dict.values[i],
		      int2->t.dict.values[i]))
	  return NO;
      return YES;
    default:
      return NO;
    }
}
	 
	 


