/** GSWMultiKeyDictionary.m - <title>GSWeb: Class GSWMultiKeyDictionary</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999

   Partially copied From GSIMap.h 
   	written by Richard Frith-Macdonald <richard@brainstorm.co.uk> 
	based on code written by Albin L. Jones <Albin.L.Jones@Dartmouth.EDU>
   
   $Revision$
   $Date$

   This file is part of the GNUstep Web Library.
   
   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include <limits.h>

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#include <GNUstepBase/GSObjCRuntime.h>
#endif

#define DEFAULT_DICTIONARY_CAPACITY 32

// Copied from NSDate.m. We should find a better solution....
static NSTimeInterval GSWTimeNow(void)
{
#if !defined(__MINGW__)
  NSTimeInterval interval;
  struct timeval tp;

  gettimeofday (&tp, NULL);
  interval = -NSTimeIntervalSince1970;
  interval += tp.tv_sec;
  interval += (double)tp.tv_usec / 1000000.0;
  return interval;
#else
  SYSTEMTIME sys_time;
  NSTimeInterval t;
#if 0
  NSCalendarDate *d;

  // Get the system time
  GetLocalTime(&sys_time);

  // Use an NSCalendar object to make it easier
  d = [NSCalendarDate alloc];
  [d initWithYear: sys_time.wYear
     month: sys_time.wMonth
     day: sys_time.wDay
     hour: sys_time.wHour
     minute: sys_time.wMinute
     second: sys_time.wSecond
     timeZone: [NSTimeZone localTimeZone]];
  t = otherTime(d);
  RELEASE(d);
#else
  /*
   * Get current GMT time, convert to NSTimeInterval since reference date,
   */
  GetSystemTime(&sys_time);
  t = GSTime(sys_time.wDay, sys_time.wMonth, sys_time.wYear, sys_time.wHour,
    sys_time.wMinute, sys_time.wSecond, sys_time.wMilliseconds); 
#endif
  return t;
#endif /* __MINGW__ */
}

typedef struct _GSWMapTable GSWMapTable_t;
typedef struct _GSWMapBase GSWMapBase_t;
typedef struct _GSWMapBucket GSWMapBucket_t;
typedef struct _GSWMapNode GSWMapNode_t;
typedef struct _GSWCacheMapNode GSWCacheMapNode_t;

typedef GSWMapTable_t *GSWMapTable;
typedef GSWMapBase_t *GSWMapBase;
typedef GSWMapBucket_t *GSWMapBucket;
typedef GSWMapNode_t *GSWMapNode;
typedef GSWCacheMapNode_t *GSWCacheMapNode;

struct	_GSWMapNode {
  GSWMapNode	nextInBucket;	/* Linked list of bucket.	*/
  id		key;
  id		value;
  GSWMapTable   subMap;		/* SubMap */
};

struct	_GSWCacheMapNode {
  // Should have same first members as _GSWMapNode
  GSWMapNode	nextInBucket;	/* Linked list of bucket.	*/
  id		key;
  id		value;
  GSWMapTable   subMap;		/* SubMap */

  NSTimeInterval firstAccessTS;
  NSTimeInterval lastAccessTS;
  NSTimeInterval cacheDuration;
  unsigned int flags;
};

struct	_GSWMapBucket {
  size_t	nodeCount;	/* Number of nodes in bucket.	*/
  GSWMapNode	firstNode;	/* The linked list of nodes.	*/
};

struct	_GSWMapBase {
  NSZone	*zone;
  NSUInteger	nodeSize;	/* Size of a node */
  GSWMapTable	firstTable;

  GSWMapTable	freeTables;	/* List of unused tables.	*/
  size_t	tableChunkCount;	/* Number of chunks in array.	*/
  GSWMapTable	*tableChunks;	/* Chunks of allocated memory.	*/

  GSWMapNode	freeNodes;	/* List of unused nodes.	*/
  size_t	nodeChunkCount;	/* Number of chunks in array.	*/
  GSWMapNode	*nodeChunks;	/* Chunks of allocated memory.	*/
};

struct	_GSWMapTable {
  GSWMapBase	base;
  GSWMapTable   nextTable;
  size_t	nodeCount;	/* Number of nodes in map.	*/
  size_t	bucketCount;	/* Number of buckets in map.	*/
  GSWMapBucket	buckets;	/* Array of buckets.		*/
};

typedef struct	_GSWMapEnumerator {
  GSWMapTable	map;		/* the map being enumerated.	*/
  GSWMapNode	node;		/* The next node to use.	*/
  size_t	bucket;		/* The next bucket to use.	*/
} *_GSIE;

#ifdef	GSI_MAP_ENUMERATOR
typedef GSI_MAP_ENUMERATOR	GSWMapEnumerator_t;
#else
typedef struct _GSWMapEnumerator GSWMapEnumerator_t;
#endif
typedef GSWMapEnumerator_t	*GSWMapEnumerator;

static GSWMapBucket GSWMapPickBucket(unsigned hash, 
                                     GSWMapBucket buckets, 
                                     size_t bucketCount)
{
  return buckets + hash % bucketCount;
}

static GSWMapBucket GSWMapBucketForKey(GSWMapTable map, id key)
{
  /*
    NSDebugFLLog(@"GSWMultiKeyDictionary",
    @"map=%p key=%@",
    map,key);
  */
  return GSWMapPickBucket([key hash],
                          map->buckets, 
                          map->bucketCount);
}

//--------------------------------------------------------------------
static void GSWMapCleanMap(GSWMapTable map);
//--------------------------------------------------------------------
static void GSWMapEmptyMap(GSWMapTable map);



//--------------------------------------------------------------------
static void GSWMapLinkNodeIntoBucket(GSWMapBucket bucket, 
                                     GSWMapNode node)
{
  node->nextInBucket = bucket->firstNode;
  bucket->firstNode = node;
}

//--------------------------------------------------------------------
static void GSWMapUnlinkNodeFromBucket(GSWMapBucket bucket, 
                                       GSWMapNode node)
{
  if (node == bucket->firstNode)
    {
      bucket->firstNode = node->nextInBucket;
    }
  else
    {
      GSWMapNode	tmp = bucket->firstNode;

      while (tmp->nextInBucket != node)
	{
	  tmp = tmp->nextInBucket;
	}
      tmp->nextInBucket = node->nextInBucket;
    }
  node->nextInBucket = 0;
}

//--------------------------------------------------------------------
static void GSWMapAddNodeToBucket(GSWMapBucket bucket, 
                                  GSWMapNode node)
{
  GSWMapLinkNodeIntoBucket(bucket, node);
  bucket->nodeCount += 1;
}

//--------------------------------------------------------------------
static void GSWMapAddNodeToMap(GSWMapTable map, 
                               GSWMapNode node)
{
  GSWMapBucket	bucket;

  bucket = GSWMapBucketForKey(map, node->key);
  GSWMapAddNodeToBucket(bucket, node);
  map->nodeCount++;
}

//--------------------------------------------------------------------
static void GSWMapRemoveNodeFromBucket(GSWMapBucket bucket, 
                                       GSWMapNode node)
{
  bucket->nodeCount--;
  GSWMapUnlinkNodeFromBucket(bucket, node);
}

//--------------------------------------------------------------------
static void GSWMapRemoveNodeFromMap(GSWMapTable map, 
                                    GSWMapBucket bkt, 
                                    GSWMapNode node)
{
  map->nodeCount--;
  GSWMapRemoveNodeFromBucket(bkt, node);
}

//--------------------------------------------------------------------
static void GSWMapRemangleBuckets(GSWMapTable map,
                                  GSWMapBucket old_buckets, 
                                  size_t old_bucketCount,
                                  GSWMapBucket new_buckets, 
                                  size_t new_bucketCount)
{
  while (old_bucketCount-- > 0)
    {
      GSWMapNode	node;

      while ((node = old_buckets->firstNode) != 0)
	{
	  GSWMapBucket	bkt;

	  GSWMapRemoveNodeFromBucket(old_buckets, node);
	  bkt = GSWMapPickBucket([node->key hash],
                                 new_buckets, 
                                 new_bucketCount);
	  GSWMapAddNodeToBucket(bkt, node);
	}
      old_buckets++;
    }
}

//--------------------------------------------------------------------
static void GSWMapMoreNodes(GSWMapTable map, unsigned required)
{
  GSWMapNode	*newArray = NULL;
  size_t	arraySize = (map->base->nodeChunkCount+1)*sizeof(GSWMapNode);

  /*
    NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p required=%u",
               map,required);
  */
#if	GS_WITH_GC == 1
  /*
   * Our nodes may be allocated from the atomic zone - but we don't want
   * them freed - so we must keep the array of pointers to memory chunks in
   * the default zone
   */
  if (map->base->zone == GSAtomicMallocZone())
    {
      newArray = (GSWMapNode*)NSZoneMalloc(NSDefaultMallocZone(), arraySize);
    }
  else
#endif
  newArray = (GSWMapNode*)NSZoneMalloc(map->base->zone, arraySize);
  if (newArray)
    {
      void*		newNodes = NULL;
      size_t		chunkCount;
      size_t		chunkSize;

      memcpy(newArray, map->base->nodeChunks, (map->base->nodeChunkCount)*sizeof(GSWMapNode));
      if (map->base->nodeChunks)
	{
	  NSZoneFree(map->base->zone, map->base->nodeChunks);
	}
      map->base->nodeChunks = newArray;

      if (required == 0)
	{
	  if (map->base->nodeChunkCount == 0)
	    {
	      chunkCount = map->bucketCount > 1 ? map->bucketCount : 2;
	    }
	  else
	    {
	      chunkCount = ((map->nodeCount>>2)+1)<<1;
	    }
	}
      else
	{
	  chunkCount = required;
	}
      /*
      NSDebugFLLog(@"GSWMultiKeyDictionary",
                   @"map=%p map->base=%p required=%u nodeSize=%u sizeof(GSWMapNode_t)=%u",
                   map,map->base,required,map->base->nodeSize,sizeof(GSWMapNode_t));
      */
      NSCAssert2(map->base->nodeSize>=sizeof(GSWMapNode_t),
                 @"Bad node size: %"PRIuPTR" < %"PRIuPTR,
                 map->base->nodeSize,
                 sizeof(GSWMapNode_t));
      chunkSize = chunkCount * map->base->nodeSize;
      newNodes = NSZoneMalloc(map->base->zone, chunkSize);
      if (newNodes)
	{
          memset(newNodes,0,chunkSize);//I HATE unitialized memory !
	  map->base->nodeChunks[map->base->nodeChunkCount++] = newNodes;
          chunkCount--;
	  ((GSWMapNode)(newNodes+(chunkCount*map->base->nodeSize)))->nextInBucket = map->base->freeNodes;
	  while (chunkCount--)
	    {
	      ((GSWMapNode)(newNodes+(chunkCount*map->base->nodeSize)))->nextInBucket = 
                (GSWMapNode)(newNodes+((chunkCount+1)*map->base->nodeSize));
              /*
              NSDebugFLLog(@"GSWMultiKeyDictionary",
                           @"newNodes[chunkCount].nextInBucket node=%p",
                           (GSWMapNode)(newNodes+(chunkCount*map->base->nodeSize)));
              */
	    }
	  map->base->freeNodes = newNodes;
          /*
          NSDebugFLLog(@"GSWMultiKeyDictionary",
                       @"map->base->freeNodes=%p",
                       map->base->freeNodes);
          */
	}
    }
}

//--------------------------------------------------------------------
static void GSWMapResize(GSWMapTable map, size_t new_capacity)
{
  GSWMapBucket	new_buckets = NULL;
  size_t	size = 1;
  size_t	old = 1;

  /*
   *	Find next size up in the fibonacci series
   */
  while (size < new_capacity)
    {
      size_t	tmp = old;

      old = size;
      size += tmp;
    }
  /*
   *	Avoid 8 - since hash functions frequently generate uneven distributions
   *	around powers of two - we don't want lots of keys falling into a single
   *	bucket.
   */
  if (size == 8)
    {
      size++;
    }

  /*
   *	Make a new set of buckets for this map
   */
  new_buckets = (GSWMapBucket)NSZoneCalloc(map->base->zone, size,
                                           sizeof(GSWMapBucket_t));
  if (new_buckets != 0)
    {
      GSWMapRemangleBuckets(map, 
                            map->buckets, 
                            map->bucketCount, new_buckets,
                            size);

      if (map->buckets != 0)
	{
	  NSZoneFree(map->base->zone, map->buckets);
	}
      map->buckets = new_buckets;
      map->bucketCount = size;
    };
}

//--------------------------------------------------------------------
static void GSWMapRightSizeMap(GSWMapTable map, size_t capacity)
{
  /* FIXME: Now, this is a guess, based solely on my intuition.  If anyone
   * knows of a better ratio (or other test, for that matter) and can
   * provide evidence of its goodness, please get in touch with me, Albin
   * L. Jones <Albin.L.Jones@Dartmouth.EDU>. */

  if (3 * capacity >= 4 * map->bucketCount)
    {
      GSWMapResize(map, (3 * capacity)/4 + 1);
    }
}


//--------------------------------------------------------------------
static void GSWMapMoreTables(GSWMapBase base, unsigned required)
{
  GSWMapTable	*newArray = NULL;
  size_t	arraySize = (base->tableChunkCount+1)*sizeof(GSWMapTable);

#if	GS_WITH_GC == 1
  /*
   * Our nodes may be allocated from the atomic zone - but we don't want
   * them freed - so we must keep the array of pointers to memory chunks in
   * the default zone
   */
  if (base->zone == GSAtomicMallocZone())
    {
      newArray = (GSWMapTable*)NSZoneMalloc(NSDefaultMallocZone(), arraySize);
    }
  else
#endif
  newArray = (GSWMapTable*)NSZoneMalloc(base->zone, arraySize);
  if (newArray)
    {
      GSWMapTable	newTables = NULL;
      size_t		chunkCount;
      size_t		chunkSize;

      memcpy(newArray, base->tableChunks, (base->tableChunkCount)*sizeof(GSWMapTable));

      if (base->tableChunks)
	{
	  NSZoneFree(base->zone, base->tableChunks);
	}
      base->tableChunks = newArray;

      if (required == 0)
	{
          chunkCount = 10;
	}
      else
	{
	  chunkCount = required;
	}

      chunkSize = chunkCount * sizeof(GSWMapTable_t);
      newTables = (GSWMapTable)NSZoneMalloc(base->zone, chunkSize);

      if (newTables)
	{
          memset(newTables,0,chunkSize);//I HATE unitialized memory !
	  base->tableChunks[base->tableChunkCount++] = newTables;
	  newTables[--chunkCount].nextTable = base->freeTables;
	  while (chunkCount--)
	    {
	      newTables[chunkCount].nextTable = &newTables[chunkCount+1];
	    }
	  base->freeTables = newTables;
	}
    }
}


//--------------------------------------------------------------------
static GSWMapNode GSWMapNewNode(GSWMapTable map, id key, id value)
{
  GSWMapNode	node = map->base->freeNodes;
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p key='%@' value=%p node=%p",
               map,map->base,key,value,node);
  */
  if (!node)
    {
      GSWMapMoreNodes(map, 0);
      node = map->base->freeNodes;
      /*
      NSDebugFLLog(@"GSWMultiKeyDictionary",
                   @"map=%p base=%p key='%@' value=%p node=%p",
                   map,map->base,key,value,node);
      */
      if (!node)
        return NULL;
    };
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p key='%@' value=%p node=%p",
               map,map->base,key,value,node);

  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p key='%@' value=%p node=%p node->nextInBucket=%p",
               map,map->base,key,value,node,node->nextInBucket);
  */
  map->base->freeNodes = node->nextInBucket;

  ASSIGN(node->key,key);
  ASSIGN(node->value,value);
  node->nextInBucket = NULL;
  node->subMap = NULL;

  return node;
}

//--------------------------------------------------------------------
static GSWMapTable GSWMapNewTableWithCapacity(GSWMapBase base,size_t capacity)
{
  GSWMapTable	table = base->freeTables;

  if (!table)
    {
      GSWMapMoreTables(base, 0);
      table = base->freeTables;
      if (!table)
        return NULL;
    }

  base->freeTables = table->nextTable;
  table->nextTable = NULL;
  table->base=base;

  table->nodeCount = 0;
  table->bucketCount = 0;
  table->buckets = NULL;
  GSWMapRightSizeMap(table, capacity);
  GSWMapMoreNodes(table, capacity);

  return table;
}

//--------------------------------------------------------------------
static void GSWMapFreeNode(GSWMapTable map, GSWMapNode node)
{
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p node=%p",
               map,map->base,node);
  */
  DESTROY(node->key);
  DESTROY(node->value);
  if (node->subMap)
    {
      GSWMapEmptyMap(node->subMap);
      node->subMap=NULL;
    };

  node->nextInBucket = map->base->freeNodes;
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p node->nextInBucket node=%p",
               map,map->base,node->nextInBucket);
  */
  map->base->freeNodes = node;
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p base=%p map->base->freeNodes node=%p",
               map,map->base, map->base->freeNodes);
  */
}

//--------------------------------------------------------------------
static void GSWMapFreeTable(GSWMapTable table)
{
  table->nextTable = table->base->freeTables;
  table->base->freeTables = table;
}

//--------------------------------------------------------------------
static GSWMapNode GSWMapNodeForKeyInBucket(GSWMapTable map, 
                                           GSWMapBucket bucket, 
                                           id key)
{
  GSWMapNode	node = bucket->firstNode;

  while (node && ![node->key isEqual:key])
    node = node->nextInBucket;
  return node;
}

//--------------------------------------------------------------------
static GSWMapNode GSWMapNodeForKey(GSWMapTable map, id key)
{
  GSWMapBucket	bucket = NULL;
  GSWMapNode	node = NULL;
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"map=%p key=%@",
               map,key);
  */
  if (map->nodeCount>0)
    {
      bucket = GSWMapBucketForKey(map, key);
      node = GSWMapNodeForKeyInBucket(map, bucket, key);
    };
  return node;
}

//--------------------------------------------------------------------
/** Enumerating **/

/* IMPORTANT WARNING: Enumerators have a wonderous property.
 * Once a node has been returned by `GSWMapEnumeratorNextNode()', it may be
 * removed from the map without effecting the rest of the current
 * enumeration. */

/* EXTREMELY IMPORTANT WARNING: The purpose of this warning is point
 * out that, various (i.e., many) functions currently depend on
 * the behaviour outlined above.  So be prepared for some serious
 * breakage when you go fudging around with these things. */

/**
 * Create an return an enumerator for the specified map.<br />
 * You must call GSWMapEndEnumerator() when you have finished
 * with the enumerator.<br />
 * <strong>WARNING</strong> You should not alter a map while an enumeration
 * is in progress.  The results of doing so are reasonably unpredictable.
 * <br />Remember, DON'T MESS WITH A MAP WHILE YOU'RE ENUMERATING IT.
 */
static GSWMapEnumerator_t GSWMapEnumeratorForMap(GSWMapTable map)
{
  GSWMapEnumerator_t	enumerator;

  enumerator.map = map;
  enumerator.node = 0;
  enumerator.bucket = 0;
  /*
   * Locate next bucket and node to be returned.
   */
  while (enumerator.bucket < map->bucketCount)
    {
      enumerator.node = map->buckets[enumerator.bucket].firstNode;
      if (enumerator.node != 0)
	{
	  break;	// Got first node, and recorded its bucket.
	}
      enumerator.bucket++;
    }

  return enumerator;
}

//--------------------------------------------------------------------
/**
 * Tidies up after map enumeration ... effectively destroys the enumerator.
 */
static void GSWMapEndEnumerator(GSWMapEnumerator enumerator)
{
  ((_GSIE)enumerator)->map = 0;
  ((_GSIE)enumerator)->node = 0;
  ((_GSIE)enumerator)->bucket = 0;
}

//--------------------------------------------------------------------
/**
 * Returns the bucket from which the next node in the enumeration will
 * come.  Once the next node has been enumerated, you can use the
 * bucket and node to remove the node from the map using the
 * GSWMapRemoveNodeFromMap() function.
 */
static GSWMapBucket GSWMapEnumeratorBucket(GSWMapEnumerator enumerator)
{
  if (((_GSIE)enumerator)->node != 0)
    {
      GSWMapTable	map = ((_GSIE)enumerator)->map;

      return &((map->buckets)[((_GSIE)enumerator)->bucket]);
    }
  return 0;
}

//--------------------------------------------------------------------
/**
 * Returns the next node in the map, or a nul pointer if at the end.
 */
static GSWMapNode GSWMapEnumeratorNextNode(GSWMapEnumerator enumerator)
{
  GSWMapNode	node = ((_GSIE)enumerator)->node;

  if (node != 0)
    {
      GSWMapNode	next = node->nextInBucket;

      if (next == 0)
	{
	  GSWMapTable	map = ((_GSIE)enumerator)->map;
	  size_t	bucketCount = map->bucketCount;
	  size_t	bucket = ((_GSIE)enumerator)->bucket;

	  while (next == 0 && ++bucket < bucketCount)
	    {
	      next = (map->buckets[bucket]).firstNode;
	    }
	  ((_GSIE)enumerator)->bucket = bucket;
	}
      ((_GSIE)enumerator)->node = next;
    }
  return node;
}

//--------------------------------------------------------------------
static GSWMapNode GSWMapAddPair(GSWMapTable map, id key, id value)
{
  GSWMapNode node = NULL;
  /*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"key='%@' value=%p",
               key,value);
  */
  node = GSWMapNewNode(map, key, value);
/*
  NSDebugFLLog(@"GSWMultiKeyDictionary",
               @"key='%@' value=%p node=%p",
               key,value,node);
*/
  if (node)
    {
      GSWMapRightSizeMap(map, map->nodeCount);
      GSWMapAddNodeToMap(map, node);
    };
  return node;
}

//--------------------------------------------------------------------
static void GSWMapRemoveKey(GSWMapTable map, id key)
{
  GSWMapBucket	bucket = GSWMapBucketForKey(map, key);
  GSWMapNode	node = NULL;
  
  node = GSWMapNodeForKeyInBucket(map, bucket, key);
  if (node)
    {
      if (node->subMap)
        {
          //Only release Value
          DESTROY(node->value);
        }
      else
        {
          // Remove Node
          GSWMapRemoveNodeFromMap(map, bucket, node);
          GSWMapFreeNode(map, node);
        };
    }
}

//--------------------------------------------------------------------
static void GSWMapMakeObjectsPerformSelector(GSWMapTable map,
                                             SEL selector)
{
  GSWMapEnumerator_t	enumerator = GSWMapEnumeratorForMap(map);
  GSWMapNode	node = GSWMapEnumeratorNextNode(&enumerator);

  while (node)
    {
      [node->value performSelector:selector];
      if (node->subMap)
        GSWMapMakeObjectsPerformSelector(node->subMap,selector);
      node = GSWMapEnumeratorNextNode(&enumerator);
    }
  GSWMapEndEnumerator(&enumerator);
};

//--------------------------------------------------------------------
static void GSWMapMakeObjectsPerformSelectorWithObject(GSWMapTable map,
                                                         SEL selector,
                                                         id object)
{
  GSWMapEnumerator_t	enumerator = GSWMapEnumeratorForMap(map);
  GSWMapNode	node = GSWMapEnumeratorNextNode(&enumerator);

  while (node)
    {
      [node->value performSelector:selector
           withObject:object];
      if (node->subMap)
        GSWMapMakeObjectsPerformSelectorWithObject(node->subMap,
                                                   selector,
                                                   object);
      node = GSWMapEnumeratorNextNode(&enumerator);
    }
  GSWMapEndEnumerator(&enumerator);
};

//--------------------------------------------------------------------
static void GSWMapMakeObjectsPerformSelectorWith2Objects(GSWMapTable map,
                                                         SEL selector,
                                                         id object1,
                                                         id object2)
{
  GSWMapEnumerator_t	enumerator = GSWMapEnumeratorForMap(map);
  GSWMapNode	node = GSWMapEnumeratorNextNode(&enumerator);

  while (node)
    {
      [node->value performSelector:selector
           withObject:object1
           withObject:object2];
      if (node->subMap)
        GSWMapMakeObjectsPerformSelectorWith2Objects(node->subMap,
                                                     selector,
                                                     object1,
                                                     object2);
      node = GSWMapEnumeratorNextNode(&enumerator);
    }
  GSWMapEndEnumerator(&enumerator);
};

//--------------------------------------------------------------------
static void GSWMapAddAllValuesIntoArray(GSWMapTable map,
                                        NSMutableArray* array)
{
  GSWMapEnumerator_t	enumerator = GSWMapEnumeratorForMap(map);
  GSWMapNode	node = GSWMapEnumeratorNextNode(&enumerator);

  while (node)
    {
      if (node->value)
        [array addObject:node->value];
      if (node->subMap)
        GSWMapAddAllValuesIntoArray(node->subMap,
                                    array);
      node = GSWMapEnumeratorNextNode(&enumerator);
    }
  GSWMapEndEnumerator(&enumerator);
};

//--------------------------------------------------------------------
static void GSWMapCleanMap(GSWMapTable map)
{
  if (map->nodeCount > 0)
    {
      GSWMapBucket	bucket = map->buckets;
      NSUInteger	i;
      GSWMapNode	startNode = 0;
      GSWMapNode	prevNode = 0;
      GSWMapNode	node = NULL;
      
      map->nodeCount = 0;
      for (i = 0; i < map->bucketCount; i++)
	{
	  node = bucket->firstNode;
	  if (prevNode)
	    {
	      prevNode->nextInBucket = node;
	    }
	  else
	    {
	      startNode = node;
	    }
	  while(node)
	    {
	      DESTROY(node->key);	  
	      DESTROY(node->value);
              if (node->subMap)
                {
                  GSWMapEmptyMap(node->subMap);
                  node->subMap=NULL;
                };
                  
	      prevNode = node;
	      node = node->nextInBucket;
	    }
	  bucket->nodeCount = 0;
	  bucket->firstNode = NULL;
	  bucket++;
	}
      
      prevNode->nextInBucket = map->base->freeNodes;
      map->base->freeNodes = startNode;
    }
}

//Really remove all (before deallocation)
//--------------------------------------------------------------------
static void GSWMapEmptyMap(GSWMapTable map)
{
  GSWMapCleanMap(map);

  if (map->buckets)
    {
      NSZoneFree(map->base->zone, map->buckets);
      map->buckets = NULL;
      map->bucketCount = 0;
    }
  GSWMapFreeTable(map);
}

//--------------------------------------------------------------------
static void GSWMapCleanBase(GSWMapBase base)
{
  GSWMapCleanMap(base->firstTable);
};

//Really remove all (before deallocation)
//--------------------------------------------------------------------
static void GSWMapEmptyBase(GSWMapBase base)
{
  NSUInteger	i=0;

  GSWMapEmptyMap(base->firstTable);
  base->firstTable=NULL;

  if (base->nodeChunks != 0)
    {
      for (i = 0; i < base->nodeChunkCount; i++)
	{
	  NSZoneFree(base->zone, base->nodeChunks[i]);
	}
      base->nodeChunkCount = 0;
      NSZoneFree(base->zone, base->nodeChunks);
      base->nodeChunks = NULL;
    }
  base->freeNodes = NULL;

  if (base->tableChunks != 0)
    {
      for (i = 0; i < base->tableChunkCount; i++)
	{
	  NSZoneFree(base->zone, base->tableChunks[i]);
	}
      base->tableChunkCount = 0;
      NSZoneFree(base->zone, base->tableChunks);
      base->tableChunks = NULL;
    }
  base->freeTables = NULL;
  base->zone = NULL;
}


//--------------------------------------------------------------------
static void GSWMapBaseInitWithZoneAndCapacity(GSWMapBase base, 
                                              NSZone *zone, 
                                              size_t capacity)
{
  base->zone = zone;

  base->nodeChunks = NULL;
  base->freeNodes = NULL;
  base->nodeChunkCount = 0;

  base->tableChunks = NULL;
  base->freeTables = NULL;
  base->tableChunkCount = 0;

  base->firstTable=GSWMapNewTableWithCapacity(base,capacity);
}


//==============================================================================
@interface GSWMultiKeyDictionaryObjectEnumerator : NSEnumerator
{
  GSWMultiKeyDictionary* _dictionary;
  NSMutableArray* _objects;
}

-(id)initWithDictionary:(GSWMultiKeyDictionary*)d;

@end

//==============================================================================
@interface GSWMultiKeyDictionary(Private)
+(id)dictionaryWithNodeSize:(NSUInteger)nodeSize;
-(id)initWithNodeSize:(NSUInteger)nodeSize;
-(id)initWithNodeSize:(NSUInteger)nodeSize
             capacity:(NSUInteger)capacity;

-(void)setObject:(id)object
         forKeys:(id*)keys
           count:(unsigned)count
     returnsNode:(GSWMapNode*)nodePtr;

-(GSWMapNode)nodeForKey:(id)key
                andKeys:(va_list)nextKeys;

-(GSWMapNode)nodeForKeys:(id*)keys
                   count:(unsigned)count;
@end

//==============================================================================
@implementation GSWMultiKeyDictionary : NSObject

//------------------------------------------------------------------------------
+(id)dictionaryWithNodeSize:(NSUInteger)nodeSize
{
  NSCAssert2(nodeSize>=sizeof(GSWMapNode_t),
             @"Bad node size: %"PRIuPTR" < %"PRIuPTR,
             nodeSize,
             sizeof(GSWMapNode_t));
  return [[self alloc]initWithNodeSize:nodeSize];
};

//------------------------------------------------------------------------------
+(id)dictionary
{
  return [self dictionaryWithNodeSize:sizeof(GSWMapNode_t)];
};

//------------------------------------------------------------------------------
-(id)initWithNodeSize:(NSUInteger)nodeSize
{
  NSCAssert2(nodeSize>=sizeof(GSWMapNode_t),
             @"Bad node size: %"PRIuPTR" < %"PRIuPTR,
             nodeSize,
             sizeof(GSWMapNode_t));
  self=[self initWithNodeSize:nodeSize
             capacity:DEFAULT_DICTIONARY_CAPACITY];
  return self;
};

//------------------------------------------------------------------------------
-(id)init
{
  self=[self initWithNodeSize:sizeof(GSWMapNode_t)];
  return self;
};

//------------------------------------------------------------------------------
-(id)initWithNodeSize:(NSUInteger)nodeSize
             capacity:(NSUInteger)capacity
{
  NSCAssert2(nodeSize>=sizeof(GSWMapNode_t),
             @"Bad node size: %"PRIuPTR" < %"PRIuPTR,
             nodeSize,
             sizeof(GSWMapNode_t));
  if ((self=[super init]))
    {
      _mapBase = (GSWMapBase)NSZoneMalloc([self zone],sizeof(GSWMapBase_t));
      ((GSWMapBase)_mapBase)->nodeSize=nodeSize;
      /*
      NSDebugMLLog(@"GSWMultiKeyDictionary",
                   @"self=%p class=%@ base=%p nodeSize=%u sizeof(GSWMapNode_t)=%u",
                   self,[self class],_mapBase,nodeSize,sizeof(GSWMapNode_t));
      */
      GSWMapBaseInitWithZoneAndCapacity((GSWMapBase)_mapBase, [self zone],
					capacity);
    };
  return self;
};

//------------------------------------------------------------------------------
-(id)initWithCapacity:(NSUInteger)capacity
{
  [self initWithNodeSize:sizeof(GSWMapNode_t)
        capacity:capacity];
  return self;
};

//------------------------------------------------------------------------------
- (void) dealloc
{
  if (_mapBase)
    {
      GSWMapEmptyBase((GSWMapBase)_mapBase);
      NSZoneFree([self zone],_mapBase);
    };
  [super dealloc];
}

//------------------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;
  //TODO
  descr=[NSString stringWithFormat:@"<%@ %p allValues=%@>",
				  NSStringFromClass([self class]),
				  (void*)self, [self allValues]];
  return descr;
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object
         forKeys:(id)key,...
{
  GS_USEIDLIST(key,[self setObject:object 
                         forKeys:__objects
                         count: __count
                         returnsNode:NULL]); 
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object
    forKeysArray:(NSArray*)keysArray
{
  int keysCount=[keysArray count];
  if (keysCount==0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Tried to add empty keys array to multi-keys dictionary. Object: %@",
                   object];
    }
  else if (object == nil)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Tried to add nil value to multi-keys dictionary"];
    }
  else
    {
      id keys[keysCount];
      [keysArray getObjects:keys];

      [self setObject:object
            forKeys:keys
            count:keysCount
            returnsNode:NULL];
    };
};

//----------------------------------------------------------------------------------------
-(void)setObject:(id)object
         forKeys:(id*)keys
           count:(unsigned)count
{
  [self setObject:object
        forKeys:keys
        count:count
        returnsNode:NULL];
}

//----------------------------------------------------------------------------------------
-(void)setObject:(id)object
         forKeys:(id*)keys
           count:(unsigned)count
     returnsNode:(GSWMapNode*)nodePtr
{
  if (count==0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Tried to add object to multi-keys dictionary with no key. Object: %@",
                   object];
    }
  else if (*keys == nil)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Tried to add nil key to multi-keys dictionary. Object: %@",
                   object];
    }
  else if (object == nil)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Tried to add nil value to multi-keys dictionary. First key: %@",
                   *keys];
    }
  else
    {
      int i=0;
      GSWMapTable	currentMap=((GSWMapBase)_mapBase)->firstTable;
      
      for(i=0;i<count;i++)
        {
          id key=keys[i];
          BOOL isNextKey=(i<(count-1) && keys[i+1]);
          GSWMapNode node  = GSWMapNodeForKey(currentMap,key);
          /*
          NSDebugMLLog(@"GSWMultiKeyDictionary",
                       @"key='%@' node=%p node->value=%p isNextKey=%d",
                       key,node,(node ? node->value : NULL),isNextKey);
          */
          if (node)
            {
              if (isNextKey)
                {
                  if (!node->subMap)
                    node->subMap=GSWMapNewTableWithCapacity(currentMap->base,DEFAULT_DICTIONARY_CAPACITY);                
                  currentMap=node->subMap;
                }
              else
                {
                  ASSIGN(node->value,object);
                  if (nodePtr)
                    *nodePtr=node;
                };
            }
          else
            {
              if (isNextKey)
                {
                  node=GSWMapAddPair(currentMap,key,nil);
                  node->subMap=GSWMapNewTableWithCapacity(currentMap->base,DEFAULT_DICTIONARY_CAPACITY);
                  currentMap=node->subMap;
                }
              else
                {
                  GSWMapNode aNode=GSWMapAddPair(currentMap,key,object);
                  if (nodePtr)
                    *nodePtr=aNode;
                };
            };
        };
    };
}

//------------------------------------------------------------------------------
-(id)objectForKeys:(id)key,...
{
  id object=nil;
  /*
  NSDebugMLLog(@"GSWMultiKeyDictionary",
               @"self=%p class=%@ key=%@",
               self,[self class],key);
  */
  GS_USEIDLIST(key,object = [self objectForKeys:__objects
                                  count: __count]); 
  return object;
};

//------------------------------------------------------------------------------
-(id)objectForKeys:(id*)keys
             count:(unsigned)count
{
  id object=nil;

  GSWMapNode node=[self nodeForKeys:keys
                        count:count];

  if (node)
    object=node->value;

  return object;
};

//----------------------------------------------------------------------------------------
-(id)objectForKeysArray:(NSArray*)keysArray
{
  id object=nil;
  int keysCount=[keysArray count];
  if (keysCount>0)
    {
      id keys[keysCount];
      [keysArray getObjects:keys];
      object=[self objectForKeys:keys
                   count:keysCount];
    };
  return object;
}

//----------------------------------------------------------------------------------------
-(GSWMapNode)nodeForKeys:(id*)keys
                   count:(unsigned)count
{
  int i=0;
  GSWMapNode finalNode=NULL;
  GSWMapTable	currentMap=((GSWMapBase)_mapBase)->firstTable;
  for(i=0;i<count;i++)
    {
      id key=keys[i];
      BOOL isNextKey=(i<(count-1) && keys[i+1]);
      GSWMapNode node  = NULL;

      /*
      NSDebugMLLog(@"GSWMultiKeyDictionary",
                   @"key[%d]='%@' isNextKey=%d",
                   i,key,isNextKey);

      NSDebugMLLog(@"GSWMultiKeyDictionary",
                   @"key[%d]=%p isNextKey=%d",
                   i,key,isNextKey);
      */
      node  = GSWMapNodeForKey(currentMap,key);
      /*
      NSDebugMLLog(@"GSWMultiKeyDictionary",
                   @"key[%d]='%@' node=%p node->value=%p isNextKey=%d",
                   i,key,node,(node ? node->value : NULL),isNextKey);
      */
      if (node)
	{
          if (isNextKey)
            {
              currentMap=node->subMap;
              if (!currentMap)
                break;
            }
          else
            finalNode=node;
	}
      else
        break;
    };
/*
  NSDebugMLLog(@"GSWMultiKeyDictionary",@"Object node %sfound: %p",
               (finalNode ? "" : "not "),finalNode);
*/
  return finalNode;
}

//------------------------------------------------------------------------------
-(void)removeAllObjects
{
  GSWMapCleanBase((GSWMapBase)_mapBase);
};

//------------------------------------------------------------------------------
-(void)removeObjectForKeys:(id)key,...
{
  GS_USEIDLIST(key,[self removeObjectForKeys:__objects
                         count: __count]); 
};

//------------------------------------------------------------------------------
-(void)removeObjectForKeysArray:(NSArray*)keysArray
{
  int keysCount=[keysArray count];
  if (keysCount>0)
    {
      id keys[keysCount];
      [keysArray getObjects:keys];
      [self removeObjectForKeys:keys
            count:keysCount];
    };
};

//----------------------------------------------------------------------------------------
-(void)removeObjectForKeys:(id*)keys
                     count:(unsigned)count
{
  int i=0;
  GSWMapTable	currentMap=((GSWMapBase)_mapBase)->firstTable;
  for(i=0;i<count;i++)
    {
      id key=keys[i];
      BOOL isNextKey=(i<(count-1) && keys[i+1]);
      GSWMapNode node  = GSWMapNodeForKey(currentMap,key);
      /*
      NSDebugMLLog(@"GSWMultiKeyDictionary",
                   @"key='%@' node=%p node->value=%p isNextKey=%d",
                   key,node,(node ? node->value : NULL),isNextKey);
*/
      if (node)
	{
          if (isNextKey)
            {
              currentMap=node->subMap;
              if (!currentMap)
                break;
            }
          else
            {
              GSWMapRemoveKey(currentMap,key);
            };
	}
      else
        break;
    };
}

//------------------------------------------------------------------------------
-(void)removeAllSubObjectsForKeys:(id)key,...
{
  GS_USEIDLIST(key,[self removeAllSubObjectsForKeys:__objects
                         count: __count]); 
};

//------------------------------------------------------------------------------
-(void)removeAllSubObjectsForKeys:(id*)keys
                            count:(unsigned)count
{
  GSWMapNode node=[self nodeForKeys:keys
                        count:count];

  if (node)
    {
      if (node->subMap)
        GSWMapCleanMap(node->subMap);
      [self removeObjectForKeys:keys
            count:count];
    };
}

//------------------------------------------------------------------------------
-(void)removeAllSubObjectsForKeysArray:(NSArray*)keysArray
{
  int keysCount=[keysArray count];
  if (keysCount>0)
    {
      id keys[keysCount];
      [keysArray getObjects:keys];
      [self removeAllSubObjectsForKeys:keys
            count:keysCount];
    };
}

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
{
  GSWMapMakeObjectsPerformSelector(((GSWMapBase)_mapBase)->firstTable,selector);
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object
{
  GSWMapMakeObjectsPerformSelectorWithObject(((GSWMapBase)_mapBase)->firstTable,selector,object);
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2
{
  GSWMapMakeObjectsPerformSelectorWith2Objects(((GSWMapBase)_mapBase)->firstTable,
                                               selector,
                                               object1,
                                               object2);
};

//------------------------------------------------------------------------------
- (NSEnumerator*) objectEnumerator
{
  return AUTORELEASE([[GSWMultiKeyDictionaryObjectEnumerator 
                        allocWithZone:NSDefaultMallocZone()] 
                       initWithDictionary: self]);
}

//------------------------------------------------------------------------------
-(NSArray*)allValues
{
  NSMutableArray* objects=(NSMutableArray*)[NSMutableArray array];
  GSWMapAddAllValuesIntoArray(((GSWMapBase)_mapBase)->firstTable,
                              objects);
  return objects;
};

//------------------------------------------------------------------------------
-(NSArray*)allSubValuesForKeys:(id)key,...
{
  NSArray* values=nil;
  /*
  NSDebugMLLog(@"GSWMultiKeyDictionary",
               @"self=%p class=%@ key=%@",
               self,[self class],key);
  */
  GS_USEIDLIST(key,values = [self allSubValuesForKeys:__objects
                                  count: __count]); 
  return values;
};

//------------------------------------------------------------------------------
-(NSArray*)allSubValuesForKeys:(id*)keys
                     count:(unsigned)count
{
  NSMutableArray* objects=nil;
  GSWMapNode node=[self nodeForKeys:keys
                        count:count];
  if (node)
    {
      NSMutableArray* objects=(NSMutableArray*)[NSMutableArray array];
      if (node->value)
        [objects addObject:node->value];
      if (node->subMap)
        GSWMapAddAllValuesIntoArray(node->subMap,
                                    objects);
    };
  return objects;
}

//------------------------------------------------------------------------------
-(NSArray*)allSubValuesForKeysArray:(NSArray*)keysArray
{
  NSArray* objects=nil;
  int keysCount=[keysArray count];
  if (keysCount>0)
    {
      id keys[keysCount];
      [keysArray getObjects:keys];
      objects=[self allSubValuesForKeys:keys
                    count:keysCount];
    };
  return objects;
}
@end

//==============================================================================
@implementation GSWMultiKeyDictionaryObjectEnumerator

//------------------------------------------------------------------------------
-(id)initWithDictionary:(GSWMultiKeyDictionary*)d
{
  if ((self=[super init]))
    {
      ASSIGN(_dictionary,((GSWMultiKeyDictionary*)d));
      ASSIGN(_objects,[_dictionary allValues]);
    };
  return self;
}

//------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_dictionary);
  DESTROY(_objects);
  [super dealloc];
}

//------------------------------------------------------------------------------
-(id)nextObject
{
  id object=nil;
  if ([_objects count]>0)
    {
      object=[_objects lastObject];
      AUTORELEASE(RETAIN(object));
      [_objects removeLastObject];
    };
  return object;
}

@end

//==============================================================================
@implementation GSWCache

//------------------------------------------------------------------------------
static BOOL isNodeExpired(GSWCacheMapNode node)
{
  if ((node->flags & GSWCacheFlags_expiresOnFirstAccess)==GSWCacheFlags_expiresOnFirstAccess)
    {
      return (node->cacheDuration>0 && (GSWTimeNow()-node->firstAccessTS)>node->cacheDuration);
    }
  else
    {
      return (node->cacheDuration>0 && (GSWTimeNow()-node->lastAccessTS)>node->cacheDuration);
    };
};

//--------------------------------------------------------------------
static void removeExpiredNodes(GSWMapTable map)
{
  GSWMapEnumerator_t	enumerator = GSWMapEnumeratorForMap(map);
  GSWMapBucket  bucket=GSWMapEnumeratorBucket(&enumerator);
  GSWCacheMapNode	node = (GSWCacheMapNode)GSWMapEnumeratorNextNode(&enumerator);
  while (node)
    {
      if (isNodeExpired(node))
        {
          if (node->subMap && node->subMap->nodeCount>0)
            {
              //Only release Value
              DESTROY(node->value);
            }
          else
            {
              // Remove Node
              GSWMapRemoveNodeFromMap(map,bucket, (GSWMapNode)node);
              GSWMapFreeNode(map, (GSWMapNode)node);
            };
        };
      if (node->subMap)
        {
          removeExpiredNodes(node->subMap);
          if (node->subMap->nodeCount==0)
            {
              GSWMapEmptyMap(node->subMap);
              node->subMap=NULL;
            };
        };
      bucket=GSWMapEnumeratorBucket(&enumerator);
      node = (GSWCacheMapNode)GSWMapEnumeratorNextNode(&enumerator);
    }
  GSWMapEndEnumerator(&enumerator);
};

//------------------------------------------------------------------------------
- (id)init
{
  if ((self = [self initWithDefaultDuration:-1 //never expires
                    defaultFlags:0]))
    {
    };
  return self;
}

//------------------------------------------------------------------------------
- (id)initWithDefaultDuration:(NSTimeInterval)defaultDuration
                 defaultFlags:(unsigned int)defaultFlags
{
  if ((self = [self initWithNodeSize:sizeof(GSWCacheMapNode_t)]))
    {
      _defaultDuration=defaultDuration;
      _defaultFlags=defaultFlags;
    };
  return self;
}

//------------------------------------------------------------------------------
- (void) dealloc
{
  [super dealloc];
}

//------------------------------------------------------------------------------
-(NSString*)description
{
  return [super description];  
};

//------------------------------------------------------------------------------
+(GSWCache*)cache
{
  return [[[GSWCache alloc] init] autorelease];
};

//------------------------------------------------------------------------------
+(GSWCache*)cacheWithDefaultDuration:(NSTimeInterval)defaultDuration
                        defaultFlags:(unsigned int)defaultFlags
{
  return [[[GSWCache alloc] initWithDefaultDuration:defaultDuration
                               defaultFlags:defaultFlags] autorelease];
};

//----------------------------------------------------------------------------------------
-(void)deleteExpiredEntries
{
  removeExpiredNodes(((GSWMapBase)_mapBase)->firstTable);
};

//------------------------------------------------------------------------------
-(GSWMapNode)nodeForKeys:(id*)keys
                   count:(unsigned)count
{
  GSWCacheMapNode node=(GSWCacheMapNode)[super nodeForKeys:keys
                                               count:count];
  if (node)
    {
      if (isNodeExpired(node))
        {
          NSDebugMLog(@"Node for object %p EXPIRED",node->value);
          [self removeObjectForKeys:keys
                count:count];
        }
      else
        {
          node->lastAccessTS=GSWTimeNow();
        };      
    };
  return (GSWMapNode)node;
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object
         forKeys:(id*)keys
           count:(unsigned)count
     returnsNode:(GSWMapNode*)nodePtr
{
  GSWCacheMapNode aNode=NULL;
  [super setObject:object
         forKeys:keys
         count:count
         returnsNode:(GSWMapNode*)&aNode];
  if (aNode)
    {
      aNode->firstAccessTS=GSWTimeNow();
      aNode->lastAccessTS=aNode->firstAccessTS;
      aNode->cacheDuration=_defaultDuration;
      aNode->flags=_defaultFlags;
    };
  if (nodePtr)
    *nodePtr=(GSWMapNode)aNode;
}

//----------------------------------------------------------------------------------------
-(void)setObject:(id)object
    withDuration:(NSTimeInterval)duration
          forKey:(id)key
{
  [self setObject:object
        withDuration:duration
        forKeys:&key
        count:1];
}

//----------------------------------------------------------------------------------------
-(void)setObject:(id)object
    withDuration:(NSTimeInterval)duration
         forKeys:(id*)keys
           count:(unsigned)count
{
  GSWCacheMapNode aNode=NULL;
  [self setObject:object
        forKeys:keys
        count:count
        returnsNode:(GSWMapNode*)&aNode];
  if (aNode)
    {
      aNode->cacheDuration=duration;
    };
};

//----------------------------------------------------------------------------------------
-(void)setObject:(id)object
    withDuration:(NSTimeInterval)duration
         forKeys:(id)key,...
{
  GS_USEIDLIST(key,[self setObject:object 
                         withDuration:duration
                         forKeys:__objects
                         count: __count]); 
};


@end

