/* getting.c: This is -*- c -*-

   This file implements the PLGet... functions

   */

#include "proplistP.h"
#include "util.h"

#include <stdio.h>
#include <stdlib.h>

char *PLGetStringDescription(proplist_t pl)
{
  /* taken from NSString.m */

  const char *src;
  char *dest;
  char *src_ptr,*dest_ptr;
  int len,quote;
  unsigned char ch;
  plptr_t internal;

  internal = (plptr_t)pl;
  src = internal->t.str.string;
  
  /* special case */
  if (strlen(src)==0) 
    {
       dest = (char*) MyMalloc(__FILE__, __LINE__, 3);
       strcpy(dest, "\"\"");
       return dest;
    }

  /* FIXME: Really should make this work with unichars. */
  
#define inrange(ch,min,max) ((ch)>=(min) && (ch)<=(max))
#define noquote(ch) (inrange(ch,'a','z') || inrange(ch,'A','Z') || inrange(ch,'0','9') || ((ch)=='_') || ((ch)=='.') || ((ch)=='$'))
#define charesc(ch) (inrange(ch,07,014) || ((ch)=='\"') || ((ch)=='\\'))
#define numesc(ch) (((ch)<=06) || inrange(ch,015,037) || ((ch)>0176))

  for (src_ptr = (char*)src, len=0,quote=0;
       (ch=*src_ptr);
       src_ptr++, len++)
    {
      if (!noquote(ch))
	{
	  quote=1;
	  if (charesc(ch))
	    len++;
	  else if (numesc(ch))
	    len+=3;
	}
    }

  /* Zero-length strings must be quoted or they will trigger parse
     errors. */
  if (*src == '\0')
    quote = 1;

  if (quote)
    len+=2;
  
  dest = (char*) MyMalloc(__FILE__, __LINE__, len+1);
  
  src_ptr = (char*) src;
  dest_ptr = dest;
  if (quote)
    *(dest_ptr++) = '\"';
  for (; (ch=*src_ptr); src_ptr++,dest_ptr++)
    {
      if (charesc(ch))
	{
	  *(dest_ptr++) = '\\';
	  switch (ch)
	    {
	    case '\a': *dest_ptr = 'a'; break;
	    case '\b': *dest_ptr = 'b'; break;
	    case '\t': *dest_ptr = 't'; break;
	    case '\n': *dest_ptr = 'n'; break;
	    case '\v': *dest_ptr = 'v'; break;
	    case '\f': *dest_ptr = 'f'; break;
	    default: *dest_ptr = ch;  /* " or \ */
	    }
	}
      else if (numesc(ch))
	{
	  *(dest_ptr++) = '\\';
	  *(dest_ptr++) = '0' + ((ch>>6)&07);
	  *(dest_ptr++) = '0' + ((ch>>3)&07);
	  *dest_ptr = '0' + (ch&07);
	}
      else
	{  /* copy literally */
	  *dest_ptr = ch;
	}
    }
  if (quote)
    *(dest_ptr++) = '\"';
  *dest_ptr = '\0';
  
  return dest;
#undef inrange
#undef noquote
#undef charesc
#undef numesc
}

char *PLGetString(proplist_t pl)
{
  /*  char *retstr = (char *)MyMalloc(__FILE__, __LINE__, strlen(((plptr_t)pl)->t.str.string)+1);
  strcpy(retstr, ((plptr_t)pl)->t.str.string);
  return retstr; */
  return ((plptr_t)pl)->t.str.string;
}
			  

char *PLGetDataDescription(proplist_t pl)
{
  /* taken from NSData.m */

  plptr_t internal;
  int length;
  char *retstr;
  int i, j;
  
  internal = (plptr_t)pl;
  
#define num2char(num) ((num) < 0xa ? ((num)+'0') : ((num)+0x57))
  length = internal->t.data.length;
  retstr = (char *)MyMalloc(__FILE__, __LINE__, 2*length+length/4+3);
  retstr[0]='<';
  for(i=0,j=1; i<length; i++,j++)
    {
      retstr[j++]=num2char((internal->t.data.data[i]>>4) & 0x0f);
      retstr[j]=num2char(internal->t.data.data[i] & 0x0f);
      if((i&0x3)==3 && i!=length-1)
	/* if we've just finished a 32-bit int, print a space */
	retstr[++j]=' ';
    }
  retstr[j++]='>';
  retstr[j]='\0';
  return retstr;
#undef num2char
}

unsigned int PLGetDataLength(proplist_t pl)
{
  plptr_t internal = (plptr_t)pl;

  return internal->t.data.length;
}

unsigned char *PLGetDataBytes(proplist_t pl)
{
  plptr_t internal = (plptr_t)pl;

  return internal->t.data.data;
}
  

char *PLGetDescriptionIndent(proplist_t pl, unsigned int level)
{
  int i;
  char *retstr;
  char *tmpstr, *tmpstr2;
  char *kdesc, *vdesc;
  plptr_t internal;

  retstr = PLGetDescription(pl);
  if((2*(level+1)+strlen(retstr))<=75)
    return retstr;

  MyFree(__FILE__, __LINE__, retstr);
  
  internal = (plptr_t)pl;
  switch(internal->type)
    {
    case PLSTRING:
      return PLGetStringDescription(pl);
      break;

    case PLDATA:
      return PLGetDataDescription(pl);
      break;

    case PLARRAY:
      retstr = (char *)MyMalloc(__FILE__, __LINE__, 3);
      sprintf(retstr, "(\n");
      if(internal->t.array.number>0)
	{
	  tmpstr=PLGetDescriptionIndent(internal->t.array.elements[0],
					level+1);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, 2*(level+1)+strlen(retstr)+strlen(tmpstr)+1);
	  sprintf(tmpstr2, "%s%*s%s", retstr, 2*(level+1), "", tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	}
      for(i=1;i<internal->t.array.number;i++)
	{
	  tmpstr=PLGetDescriptionIndent(internal->t.array.elements[i],
					level+1);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, 2*(level+1)+strlen(retstr)+strlen(tmpstr)+3);
	  sprintf(tmpstr2, "%s,\n%*s%s", retstr, 2*(level+1), "", tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	}
      tmpstr=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+2*level+3);
      sprintf(tmpstr, "%s\n%*s)", retstr, 2*level, "");
      MyFree(__FILE__, __LINE__, retstr);
      retstr=tmpstr;
      break;

    case PLDICTIONARY:
      retstr = (char *)MyMalloc(__FILE__, __LINE__, 3);
      sprintf(retstr, "{\n");
      for(i=0;i<internal->t.dict.number;i++)
	{
	  kdesc = PLGetDescriptionIndent(internal->t.dict.keys[i],
					 level+1);
	  vdesc = PLGetDescriptionIndent(internal->t.dict.values[i],
					 level+1);
	  
	  tmpstr=(char *)MyMalloc(__FILE__, __LINE__, 2*(level+1)+strlen(retstr)+
				strlen(kdesc)+strlen(vdesc)+6);
	  sprintf(tmpstr, "%s%*s%s = %s;\n", retstr, 2*(level+1), "",
		  kdesc, vdesc);
	  MyFree(__FILE__, __LINE__, kdesc);
	  MyFree(__FILE__, __LINE__, vdesc);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr;
	}
      tmpstr=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+2*level+2);
      sprintf(tmpstr, "%s%*s}", retstr, 2*level, "");
      MyFree(__FILE__, __LINE__, retstr);
      retstr=tmpstr;
    }

  return retstr;
}

char *PLGetDescription(proplist_t pl)
{
  int i;
  char *retstr = NULL;
  char *tmpstr, *tmpstr2;
  plptr_t internal;

  internal = (plptr_t)pl;
  switch(internal->type)
    {
    case PLSTRING:
      return PLGetStringDescription(pl);
      break;

    case PLDATA:
      return PLGetDataDescription(pl);
      break;

    case PLARRAY:
      retstr = (char *)MyMalloc(__FILE__, __LINE__, 2);
      sprintf(retstr, "(");
      if(internal->t.array.number>0)
	{
	  tmpstr=PLGetDescription(internal->t.array.elements[0]);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+strlen(tmpstr)+1);
	  sprintf(tmpstr2, "%s%s", retstr, tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	}
      for(i=1;i<internal->t.array.number;i++)
	{
	  tmpstr=PLGetDescription(internal->t.array.elements[i]);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+strlen(tmpstr)+3);
	  sprintf(tmpstr2, "%s, %s", retstr, tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	}
      tmpstr=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+2);
      sprintf(tmpstr, "%s)", retstr);
      MyFree(__FILE__, __LINE__, retstr);
      retstr=tmpstr;
      break;

    case PLDICTIONARY:
      retstr = (char *)MyMalloc(__FILE__, __LINE__, 2);
      sprintf(retstr, "{");
      for(i=0;i<internal->t.dict.number;i++)
	{
	  tmpstr=PLGetDescription(internal->t.dict.keys[i]);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+strlen(tmpstr)+4);
	  sprintf(tmpstr2, "%s%s = ", retstr, tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	  tmpstr=PLGetDescription(internal->t.dict.values[i]);
	  tmpstr2=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+strlen(tmpstr)+2);
	  sprintf(tmpstr2, "%s%s;", retstr, tmpstr);
	  MyFree(__FILE__, __LINE__, tmpstr);
	  MyFree(__FILE__, __LINE__, retstr);
	  retstr=tmpstr2;
	}
      tmpstr=(char *)MyMalloc(__FILE__, __LINE__, strlen(retstr)+2);
      sprintf(tmpstr, "%s}", retstr);
      MyFree(__FILE__, __LINE__, retstr);
      retstr=tmpstr;
    }

  return retstr;
}

unsigned int PLGetNumberOfElements(proplist_t pl)
{
  plptr_t internal;
  
  if(!PLIsCompound(pl)) return 0;

  internal = (plptr_t)pl;
  switch(internal->type)
    {
    case PLARRAY:
      return internal->t.array.number;
    case PLDICTIONARY:
      return internal->t.dict.number;
    default:
      return 0;
    }
}

proplist_t PLGetArrayElement(proplist_t pl, unsigned int index)
{
  plptr_t internal;

  internal = (plptr_t)pl;
  if(index>internal->t.array.number-1)
    return NULL;
  return internal->t.array.elements[index];
}

proplist_t PLGetAllDictionaryKeys(proplist_t pl)
{
  plptr_t internal;
  proplist_t ret;
  int i;
  
  internal = (plptr_t)pl;

  ret = PLMakeArrayFromElements(NULL);
  for(i=0;i<internal->t.dict.number;i++)
    PLAppendArrayElement(ret, internal->t.dict.keys[i]);

  return ret;
}
  
proplist_t PLGetDictionaryEntry(proplist_t pl, proplist_t key)
{
  int i;
  plptr_t internal;

  internal = (plptr_t)pl;
  if(!internal) return NULL;
  if(internal->type != PLDICTIONARY)
    return NULL;

  for(i=0;i<internal->t.dict.number;i++)
    if(PLIsEqual(internal->t.dict.keys[i], key))
      return internal->t.dict.values[i];

  return NULL;
}

proplist_t PLGetContainer(proplist_t pl)
{
  plptr_t internal = (plptr_t)pl;
  return internal->container;
}

