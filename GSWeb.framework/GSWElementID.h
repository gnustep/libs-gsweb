/** GSWElementID.h - <title>GSWeb: Class GSWElementID</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Dec 2004
      
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

// $Id$

#ifndef _GSWElementID_h__
	#define _GSWElementID_h__


typedef struct _GSWElementIDPart
{
  int _number;
  NSString* _string;  
  NSMutableString* _elementIDString; //ElementID of this part
  IMP _elementIDString_setStringIMP;
} GSWElementIDPart;

GSWEB_EXPORT SEL appendZeroElementIDComponentSEL;
GSWEB_EXPORT SEL deleteLastElementIDComponentSEL;

//====================================================================
#define GSWElementID_DefaultElementPartsCount	128

@interface GSWElementID : NSObject <NSCoding,NSCopying>
{
  GSWElementIDPart* _parts; 		/** dynamic array of GSWElementIDPart **/

  int _allocatedPartsCount;		/** number of currently allocated parts **/
  int _partsCount;			/** number of used parts (number of elemens in the current elementID **/
  int _builtPartCount;			/** number of parts which have a built _elementIDString **/

  NSMutableString* _tmpString;		/** a mutable string for manipulations **/
  IMP _tmpString_appendStringIMP;	/** _tmpString -appendString: IMP **/
  IMP _tmpString_setStringIMP;		/** _tmpString -setString: IMP **/

  NSString* _elementIDString;		/** cached current elementIDString **/

  NSString* _isSearchOverLastSenderIDString;	/** cached last isSearchOver sender ID string **/
  GSWElementID* _isSearchOverLastSenderID;	/** cache elementID built from _isSearchOverLastSenderIDString **/

  IMP _deleteElementsFromIndexIMP;	/** -_deleteElementsFromIndex IMP **/
  IMP _buildElementPartsIMP;		/** -_buildElementParts IMP **/
};

/** Returns a elementID **/
+(GSWElementID*)elementID;

/** Returns elementID initialized with 'string' **/
+(GSWElementID*)elementIDWithString:(NSString*)string;

/** Base initializer
partsCount is the number of parts to allocate
**/
-(id)initWithPartsCountCapacity:(int)partsCount;

/** Initialize from 'string' elementID
**/
-(id)initWithString:(NSString*)string;

-(BOOL)isSearchOverForSenderID:(NSString*)senderID;
-(BOOL)isParentSearchOverForSenderID:(NSString*)senderID;

/** empties elementID **/
-(void)deleteAllElementIDComponents;

/** Deletes last elementID part **/
-(void)deleteLastElementIDComponent;

/** Increments last elementID part **/
-(void)incrementLastElementIDComponent;

/** Append zero element ID after last elementID part **/
-(void)appendZeroElementIDComponent;

/** Append 'element' element ID after last elementID part 
You should avoid element ending with digits.
**/
-(void)appendElementIDComponent:(id)_element;

/** Returns parent element ID **/
-(NSString*)parentElementIDString;

/** returns number of element ID parts **/
-(int)elementsCount;

/** Returns elementID string representation or empty string if there's not 
elements **/
-(NSString*)elementIDString;
@end

#endif //_GSWElementID_h__


