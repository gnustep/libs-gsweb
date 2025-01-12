/* modifying.c: This is -*- c -*- */

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "proplistP.h"
#include "util.h"
#include "plconf.h"

#ifdef DEBUG
extern unsigned long num_objects;
#endif

proplist_t PLMakeString(char *bytes)
{
  plptr_t internal = (plptr_t)MyMalloc(__FILE__, __LINE__, sizeof(plint_t));
  internal->type = PLSTRING;
  internal->filename = NULL;
  internal->container = NULL;
  internal->changed = YES;
  internal->retain_count = 1;

  if(!bytes)
    internal->t.str.string = NULL;
  else
    {
      internal->t.str.string = (char *)MyMalloc(__FILE__, __LINE__, strlen(bytes)+1);
      strcpy(internal->t.str.string, bytes);
    }
#ifdef DEBUG
  num_objects++;
  printf("Created string %s\n", internal->t.str.string);
  printf("\t(count: %ld, num_objects: %ld)\n", internal->retain_count,
	 num_objects);
#endif
  
  return (proplist_t)internal;
}

proplist_t PLMakeData(unsigned char *data, unsigned int length)
{
  plptr_t internal = (plptr_t)MyMalloc(__FILE__, __LINE__, sizeof(plint_t));
  internal->type = PLDATA;
  internal->filename = NULL;
  internal->container = NULL;
  internal->changed = YES;
  internal->retain_count = 1;
  if(!length)
    internal->t.data.data = NULL;
  else
    {
      internal->t.data.data = (unsigned char *)MyMalloc(__FILE__, __LINE__, length);
      memcpy(internal->t.data.data, data, length);
    }
  internal->t.data.length = length;
#ifdef DEBUG
  num_objects++;
  printf("Created data %s\n", PLGetDescription((proplist_t)internal));
  printf("\t(count: %ld, num_objects: %ld)\n", internal->retain_count,
	 num_objects);
#endif
  return (proplist_t)internal;
}

proplist_t PLMakeArrayFromElements(proplist_t pl, ...)
{
  va_list ap;
  plptr_t internal = (plptr_t)MyMalloc(__FILE__, __LINE__, sizeof(plint_t));
  proplist_t current;
  proplist_t *tmplist;
  int i;
  
  internal->type = PLARRAY;
  internal->filename = NULL;
  internal->container = NULL;
  internal->changed = YES;
  internal->retain_count = 1;
  internal->t.array.elements = NULL;
  internal->t.array.number = 0;
  
  va_start(ap, pl);
  current = pl;
  if(!current) /* empty array */
    {
      va_end(ap);
#ifdef DEBUG
      num_objects++;
      printf("Created array %s\n", PLGetDescription((proplist_t)internal));
      printf("\t(count: %ld, num_objects: %ld)\n",
	     internal->retain_count, num_objects);
#endif
      return (proplist_t)internal;
    }

  do
    {
      PLRetain(current);
      tmplist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.array.number+1)*
				     sizeof(proplist_t));
      if (internal->t.array.number > 0) {
          memcpy(tmplist, internal->t.array.elements,
                 internal->t.array.number*sizeof(proplist_t));
      }
      tmplist[internal->t.array.number] = current;
      if(internal->t.array.number > 0)
          MyFree(__FILE__, __LINE__, internal->t.array.elements);
      internal->t.array.elements = tmplist;
      internal->t.array.number++;
    }  while((current = va_arg(ap, proplist_t)));

  va_end(ap);
  for(i=0;i<internal->t.array.number;i++)
    {
      ((plptr_t)internal->t.array.elements[i])->container =
	(proplist_t)internal;
      ((plptr_t)internal->t.array.elements[i])->changed = YES;
    }

#ifdef DEBUG
  num_objects++;
  printf("Created array %s\n", PLGetDescription((proplist_t)internal));
  printf("\t(count: %ld, num_objects: %ld)\n", internal->retain_count,
	 num_objects);
#endif
  return (proplist_t) internal;
}

proplist_t PLInsertArrayElement(proplist_t array, proplist_t pl,
				unsigned int index)
{
  proplist_t *tmplist;
  plptr_t internal, tmp;
  int n;

  internal = (plptr_t)array;
  
  if(index>internal->t.array.number) return NULL;

  tmplist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.array.number+1)*
				 sizeof(proplist_t));
  if (internal->t.array.number > 0 && index > 0)
      memcpy(tmplist, internal->t.array.elements, index*sizeof(proplist_t));
  tmplist[index] = pl;
  if (internal->t.array.number > index) {
      memcpy(&(tmplist[index+1]), &(internal->t.array.elements[index]),
             (internal->t.array.number-index)*sizeof(proplist_t));
  }
  if(internal->t.array.number > 0)
      MyFree(__FILE__, __LINE__, internal->t.array.elements);
  internal->t.array.elements = tmplist;
  internal->t.array.number++;

  ((plptr_t)internal->t.array.elements[index])->container =
    (proplist_t)internal;
  if(internal->filename)
    PLSetFilename(internal->t.array.elements[index], internal->filename);

  /* We need to retain as many times as the array is already retained
   * because else if one of the retainers releases the array, we lose
   * the element and may crash trying to access already free'd memory
   * from other places where the array is retained. -Dan
   */
  n = internal->retain_count;
  while (n>0) {
      PLRetain(pl);
      n--;
  }
  
  internal->changed = YES;

  /*((plptr_t)pl)->changed = YES;*/
  
  tmp = internal;
  while((tmp = tmp->container))
    tmp->changed = YES;
  
  return (proplist_t) internal;
}

proplist_t PLRemoveArrayElement(proplist_t array, unsigned int index)
{
  proplist_t *tmplist;
  plptr_t internal, tmp;
  int n;

  internal = (plptr_t)array;
  if(index>(internal->t.array.number-1)) return NULL;

  /* This needs to be released as many times as the container array is
   * retained because else we will lose references to the element and
   * will leak memory. -Dan
   */
  n = internal->retain_count;
  while (n > 0) {
      PLRelease(internal->t.array.elements[index]);
      n--;
  }

  if(internal->t.array.number > 1)
    {
      tmplist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.array.number-1)*
				     sizeof(proplist_t));
      memcpy(tmplist, internal->t.array.elements, index*sizeof(proplist_t));
      memcpy(&(tmplist[index]), &(internal->t.array.elements[index+1]),
	     (internal->t.array.number-index-1)*sizeof(proplist_t));
    }
  else
    tmplist = NULL;
  MyFree(__FILE__, __LINE__, internal->t.array.elements);
  internal->t.array.elements = tmplist;
  internal->t.array.number--;

  internal->changed = YES;
  
  tmp = internal;
  while((tmp = tmp->container))
    tmp->changed = YES;
  
  return (proplist_t) internal;
}

proplist_t PLAppendArrayElement(proplist_t array, proplist_t pl)
{
  return PLInsertArrayElement(array, pl, ((plptr_t)array)->t.array.number);
}

proplist_t PLMakeDictionaryFromEntries(proplist_t key, proplist_t value,
				       ...)
{
  va_list ap;
  plptr_t internal;
  proplist_t current_key, current_value;
  proplist_t *tmp_klist, *tmp_vlist;

  internal = (plptr_t)MyMalloc(__FILE__, __LINE__, sizeof(plint_t));

  internal->type = PLDICTIONARY;
  internal->filename = NULL;
  internal->container = NULL;
  internal->changed = YES;
  internal->retain_count = 1;
  internal->t.dict.keys = NULL;
  internal->t.dict.values = NULL;
  internal->t.dict.number = 0;

  current_key = key; current_value = value;

  if(!key || !value)
    {
#ifdef DEBUG
      num_objects++;
      printf("Created dict %s\n", PLGetDescription((proplist_t)internal));
      printf("\t(count: %ld, num_objects: %ld)\n",
	     internal->retain_count, num_objects);
#endif
      return internal;
    }

  va_start(ap, value);

  do
    {
      tmp_klist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.dict.number+1)*
                                         sizeof(proplist_t));
      tmp_vlist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.dict.number+1)*
                                         sizeof(proplist_t));
      if (internal->t.dict.number > 0) {
          memcpy(tmp_klist, internal->t.dict.keys,
                 internal->t.dict.number*sizeof(proplist_t));
          memcpy(tmp_vlist, internal->t.dict.values,
                 internal->t.dict.number*sizeof(proplist_t));
      }
      tmp_klist[internal->t.dict.number] = current_key;
      ((plptr_t)current_key)->container = internal;
      tmp_vlist[internal->t.dict.number] = current_value;
      ((plptr_t)current_value)->container = internal;

      if(internal->t.dict.number)
	{
	  MyFree(__FILE__, __LINE__, internal->t.dict.keys);
	  MyFree(__FILE__, __LINE__, internal->t.dict.values);
	}
      internal->t.dict.keys = tmp_klist;
      internal->t.dict.values = tmp_vlist;

      ((plptr_t)current_key)->changed = YES;
      ((plptr_t)current_value)->changed = YES;
      PLRetain(current_key); PLRetain(current_value);
      
      internal->t.dict.number++;

      current_key = va_arg(ap, proplist_t);
      if(!current_key)
	{
	  va_end(ap);
#ifdef DEBUG
	  num_objects++;
	  printf("Created dict %s\n", PLGetDescription((proplist_t)internal));
	  printf("\t(count: %ld, num_objects: %ld)\n",
		 internal->retain_count, num_objects);
#endif
	  return internal;
	}
      current_value = va_arg(ap, proplist_t);
      if(!current_value)
	{
	  va_end(ap);
#ifdef DEBUG
	  num_objects++;
	  printf("Created dict %s\n", PLGetDescription((proplist_t)internal));
	  printf("\t(count: %ld, num_objects: %ld)\n",
		 internal->retain_count, num_objects);
#endif
	  return internal;
	}
    } while(1);
}

proplist_t PLInsertDictionaryEntry(proplist_t dict, proplist_t key,
				   proplist_t value)
{
  plptr_t internal, tmp;
  proplist_t *tmp_klist, *tmp_vlist;
  int n;

  if(!key || !value) return NULL;

  if(PLGetDictionaryEntry(dict, key))
    PLRemoveDictionaryEntry(dict, key);

  internal = (plptr_t)dict;

  tmp_klist = (proplist_t *) MyMalloc(__FILE__, __LINE__,
				      (internal->t.dict.number+1)*
				      sizeof(proplist_t));
  tmp_vlist = (proplist_t *) MyMalloc(__FILE__, __LINE__,
				      (internal->t.dict.number+1)*
				      sizeof(proplist_t));
  if (internal->t.dict.number > 0) {
      memcpy(tmp_klist, internal->t.dict.keys,
             internal->t.dict.number*sizeof(proplist_t));
      memcpy(tmp_vlist, internal->t.dict.values,
             internal->t.dict.number*sizeof(proplist_t));
  }
  tmp_klist[internal->t.dict.number] = key;
  tmp_vlist[internal->t.dict.number] = value;

  if(internal->t.dict.number)
    {
      MyFree(__FILE__, __LINE__, internal->t.dict.keys);
      MyFree(__FILE__, __LINE__, internal->t.dict.values);
    }
  internal->t.dict.keys = tmp_klist;
  internal->t.dict.values = tmp_vlist;

  /* This is a total mess. a proplist item can have only one container,
   * but it can be inserted in many places (dictionaries or arrays).
   * Each time is inserted in another place its container changes accordingly.
   * But if its last container is released, accessing it from the other
   * places will cause an invalid memory pointer and very likely a crash, when
   * the while((tmp = tmp->container)) stuff is done below.
   * The only way to avoid this is to PLDeepCopy the object not to use the
   * retain mechanism with all the consequences, making the advantadges of
   * retaining be lost. -Dan
   *
   * Here is an example to make things clearer:
   * we have 2 dictionaries dict1 and dict2, and our object obj
   *   PLInsertDictionaryEntry(dict1, key, obj);
   * obj->container = dict1
   * obj->retain_count = 1
   *   PLInsertDictionaryEntry(dict2, key, obj);
   * obj->container = dict2
   * obj->retain_count = 2
   *   PLRelease(dict2);
   * obj->container = dict2 !!!
   * obj->retain_count = 1
   *
   * Now if obj is a dict itself and you try to do something like:
   *   PLInsertDictionaryEntry(obj, key1, value1);
   * it will crash when tmp->container will read the old released dict2
   * in the while() below.
   * Also trying to synchronize dict1 can have the same result.
   *
   * Note that obj is a valid object at this point since it was retained
   * and still exist.
   *
   */
  ((plptr_t)key)->container = internal;
  ((plptr_t)value)->container = internal;
  
  internal->t.dict.number++;

  if(internal->filename)
    {
      PLSetFilename(key, internal->filename);
      PLSetFilename(value, internal->filename);
    }

  internal->changed = YES;

  /* here will be the problem noted above */
  tmp = internal;
  while((tmp = tmp->container))
    tmp->changed = YES;


  /* We need to retain as many times as the dict is already retained
   * because else if one of the retainers releases the dict, we lose
   * the key and value and may crash trying to access already free'd
   * memory from other places where the dict is retained. -Dan
   */
  n = internal->retain_count;
  while (n > 0) {
      PLRetain(key);
      PLRetain(value);
      n--;
  }

  return (proplist_t) internal;
}

proplist_t PLRemoveDictionaryEntry(proplist_t dict, proplist_t key)
{
  plptr_t internal, tmp;
  proplist_t *tmp_klist, *tmp_vlist;
  int i, n;

  if(!PLGetDictionaryEntry(dict, key)) return NULL;

  internal = (plptr_t)dict;
  
  i=0;
  while(!PLIsEqual(internal->t.dict.keys[i], key))
    i++;

  /* This needs to be released as many times as the container dict is
   * retained because else we will lose references to the key and value
   * and will leak memory. -Dan
   */
  n = internal->retain_count;
  while (n > 0) {
      PLRelease(internal->t.dict.keys[i]);
      PLRelease(internal->t.dict.values[i]);
      n--;
  }

  if(internal->t.dict.number > 1)
    {
      tmp_klist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.dict.number-1)*
				       sizeof(proplist_t));
      tmp_vlist = (proplist_t *)MyMalloc(__FILE__, __LINE__, (internal->t.dict.number-1)*
				       sizeof(proplist_t));
      memcpy(tmp_klist, internal->t.dict.keys, i*sizeof(proplist_t));
      memcpy(&(tmp_klist[i]), &(internal->t.dict.keys[i+1]),
	     (internal->t.dict.number-i-1)*sizeof(proplist_t));
      memcpy(tmp_vlist, internal->t.dict.values, i*sizeof(proplist_t));
      memcpy(&(tmp_vlist[i]), &(internal->t.dict.values[i+1]),
	     (internal->t.dict.number-i-1)*sizeof(proplist_t));
  
      MyFree(__FILE__, __LINE__, internal->t.dict.keys);
      MyFree(__FILE__, __LINE__, internal->t.dict.values);
      internal->t.dict.keys = tmp_klist;
      internal->t.dict.values = tmp_vlist;
    }
  else
    {
      MyFree(__FILE__, __LINE__, internal->t.dict.keys);
      MyFree(__FILE__, __LINE__, internal->t.dict.values);
      internal->t.dict.keys = NULL;
      internal->t.dict.values = NULL;
    }
  
  internal->t.dict.number--;
  internal->changed = YES;

  tmp = internal;
  while((tmp = tmp->container))
    tmp->changed = YES;
  
  return internal;
}

proplist_t PLMergeDictionaries(proplist_t dest, proplist_t source)
{
  plptr_t int_source;
  int i;

  int_source = (plptr_t)source;
  for(i=0;i<int_source->t.dict.number;i++)
    PLInsertDictionaryEntry(dest, int_source->t.dict.keys[i],
			    int_source->t.dict.values[i]);

  return dest;
}


