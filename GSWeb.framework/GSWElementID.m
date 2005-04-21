/** GSWElementID.m - <title>GSWeb: Class GSWElementID</title>

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

/*
  ElementID parts are stored in GSWElementIDPart.

  We don't care too much about memory as the should be no more than 2 GSWElementIDs 
  created temporarily per context (the current elementID and the senderElementID

  o About GSWElementIDPart:

  	_string: if elementID part is a string, _string is this string and _number 
		is the incremented part otherwise

        _number: if the elementID is not a string, it's the lementID, otherwise it's the 
		incremented part of the string

        _elementIDString: is a cache of the elementID string from first part to this part.
  		it is a mutable string to avoid too much string allocation/deallocation

        _elementIDString_setStringIMP; is the IMP for _elementIDString -setString:


  o About GSWElementID:

  _parts: is a dynamic array of GSWElementIDPart. We first alloc 
		GSWElementID_DefaultElementPartsCount

  _allocatedPartsCount: is the number of allocated parts 

  _partsCount: is the count of used parts

  _builtPartsCount: is the number of GSWElementIDPart which have their 
		elementIDString built

  _tmpString: is a working NSMutableString. There's no eed for locking since GSWElementID 
  		is a 'mutable'  object used only internally during a request life.

  _tmpString_appendStringIMP: is the IMP for _tmpString -appendString:

  _tmpString_setStringIMP: is the IMP for _tmpString -setString:

  _elementIDString: is the current non mutable elementIDstring (it will save a string 
		creation when elementIDString is called more than one time without changes; 
		otherwise, it cost nothing as we have to create it anywat

  _isSearchOverLastSenderIDString: is the parameter of last isSearchOver call. We cache isSearchOverLastSenderID 
		is it will be rused multiple times but we cache if the senderID is non mutable 
		(wich should always be the case).

  _isSearchOverLastSenderID: is the elementID built from isSearchOverLastSenderIDString

  _deleteElementsFromIndexIMP: IMP of -_deleteElementsFromIndex
  _buildElementIMP: IMP of -_buildElement


  Manuel Guesdon
*/

NSString* GSWElementIDPartDescription(GSWElementIDPart* part)
{
  return [NSString stringWithFormat:@"<GSWElementIDPart %p: number: %d string: %@ elementID: %@ IMP: %p",
                   part,
                   part->_number,
                   part->_string,
                   part->_elementIDString,
                   part->_elementIDString_setStringIMP];
};

//====================================================================
@implementation GSWElementID

// 'Standard' GSWElementID class. Used to get IMPs from standardElementIDIMPs
static Class standardClass=Nil;

// List of standardClass IMPs
static GSWElementIDIMPs standardElementIDIMPs;

// Internal Selectors
static SEL deleteElementsFromIndexSelector = NULL;
static SEL buildElementPartsSelector = NULL;
static SEL appendStringSelector = NULL;
static SEL setStringSelector = NULL;

// Public Selectors
SEL appendZeroElementIDComponentSEL=NULL;
SEL deleteLastElementIDComponentSEL=NULL;
SEL incrementLastElementIDComponentSEL=NULL;
SEL appendElementIDComponentSEL=NULL;
SEL deleteAllElementIDComponentsSEL=NULL;
SEL isParentSearchOverForSenderIDSEL=NULL;
SEL isSearchOverForSenderIDSEL=NULL;
SEL elementIDStringSEL=NULL;


//--------------------------------------------------------------------
// Fill impsPtr structure with IMPs for elementID
void GetGSWElementIDIMPs(GSWElementIDIMPs* impsPtr,GSWElementID* elementID)
{
  NSCAssert(elementID,@"No elementID in GetGSWElementIDIMPs()");
  if ([elementID class]==standardClass)
    {
      memcpy(impsPtr,&standardElementIDIMPs,sizeof(GSWElementIDIMPs));
    }
  else
    {
      memset(&standardElementIDIMPs,0,sizeof(GSWElementIDIMPs));

      impsPtr->_incrementLastElementIDComponentIMP = 
        [elementID methodForSelector:incrementLastElementIDComponentSEL];

      impsPtr->_appendElementIDComponentIMP = 
        [elementID methodForSelector:appendElementIDComponentSEL];

      impsPtr->_appendZeroElementIDComponentIMP = 
        [elementID methodForSelector:appendZeroElementIDComponentSEL];

      impsPtr->_deleteAllElementIDComponentsIMP = 
        [elementID methodForSelector:deleteAllElementIDComponentsSEL];

      impsPtr->_deleteLastElementIDComponentIMP = 
        [elementID methodForSelector:deleteLastElementIDComponentSEL];

      impsPtr->_isParentSearchOverForSenderIDIMP = 
        (GSWIMP_BOOL)[elementID methodForSelector:isParentSearchOverForSenderIDSEL];

      impsPtr->_isSearchOverForSenderIDIMP = 
        (GSWIMP_BOOL)[elementID methodForSelector:isSearchOverForSenderIDSEL];

      impsPtr->_elementIDStringIMP = 
        [elementID methodForSelector:elementIDStringSEL];
    };
};

//--------------------------------------------------------------------
// Initialize GSWElementID selectors
void InitializeGSWElementIDSELs()
{
  static BOOL initialized=NO;
  if (!initialized)
    {
      incrementLastElementIDComponentSEL = @selector(incrementLastElementIDComponent);
      appendElementIDComponentSEL = @selector(appendElementIDComponent:);
      appendZeroElementIDComponentSEL=@selector(appendZeroElementIDComponent);
      deleteAllElementIDComponentsSEL = @selector(deleteAllElementIDComponents);
      deleteLastElementIDComponentSEL=@selector(deleteLastElementIDComponent);
      isParentSearchOverForSenderIDSEL = @selector(isParentSearchOverForSenderID:);
      isSearchOverForSenderIDSEL = @selector(isSearchOverForSenderID:);
      elementIDStringSEL = @selector(elementIDString);
      initialized=YES;
    };
};

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWElementID class])
    {
      deleteElementsFromIndexSelector=@selector(_deleteElementsFromIndex:);
      buildElementPartsSelector=@selector(_buildElementParts);
      appendStringSelector=@selector(appendString:);
      setStringSelector=@selector(setString:);

      InitializeGSWElementIDSELs();
      memset(&standardElementIDIMPs,0,sizeof(GSWElementIDIMPs));
      [self setStandardClass:[GSWElementID class]];
    };
};

//--------------------------------------------------------------------
+(void)setStandardClass:(Class)aStandardClass
{
  // TODO MultiThread protection
  standardClass=aStandardClass;

  memset(&standardElementIDIMPs,0,sizeof(GSWElementIDIMPs));

  standardElementIDIMPs._incrementLastElementIDComponentIMP = 
    [self instanceMethodForSelector:incrementLastElementIDComponentSEL];

  standardElementIDIMPs._appendElementIDComponentIMP = 
    [self instanceMethodForSelector:appendElementIDComponentSEL];

  standardElementIDIMPs._appendZeroElementIDComponentIMP = 
    [self instanceMethodForSelector:appendZeroElementIDComponentSEL];

  standardElementIDIMPs._deleteAllElementIDComponentsIMP = 
    [self instanceMethodForSelector:deleteAllElementIDComponentsSEL];

  standardElementIDIMPs._deleteLastElementIDComponentIMP = 
    [self instanceMethodForSelector:deleteLastElementIDComponentSEL];

  standardElementIDIMPs._isParentSearchOverForSenderIDIMP = 
    (GSWIMP_BOOL)[self instanceMethodForSelector:isParentSearchOverForSenderIDSEL];

  standardElementIDIMPs._isSearchOverForSenderIDIMP = 
    (GSWIMP_BOOL)[self instanceMethodForSelector:isSearchOverForSenderIDSEL];

  standardElementIDIMPs._elementIDStringIMP = 
    [self instanceMethodForSelector:elementIDStringSEL];      
};

//--------------------------------------------------------------------
/** Allocate or reallocate allocPartsCount elements. Previous parts are in *partsPtr;
previously allocated parts count is in *allocatedPartsCountPtr.
New parts is stored id *partsPtr and new allocated parts count in *allocatedPartsCountPtr
**/
void GSWElementIDRealloc(GSWElementIDPart** partsPtr,int* allocatedPartsCountPtr,int allocPartsCount)
{
  NSDebugFLLog(@"GSWElementID",
               @"*partsPtr=%p *allocatedPartsCountPtr=%d allocPartsCount=%d",
               *partsPtr,*allocatedPartsCountPtr,allocPartsCount);

  //Really need ?  
  if (allocPartsCount>*allocatedPartsCountPtr)
    {
      int allocSize=allocPartsCount*sizeof(GSWElementIDPart);
      int allocatedSize=(*allocatedPartsCountPtr)*sizeof(GSWElementIDPart);
      GSWElementIDPart* newParts=NULL;

      newParts=NSZoneMalloc(NSDefaultMallocZone(),allocSize);
      NSCAssert2(newParts,@"Can't alloc %d parts (allocSize bytes)",
                 allocPartsCount,
                 allocSize);
      NSDebugFLLog(@"GSWElementID",@"allocSize=%d newParts=%p",
                   allocSize,newParts);

      if ((*allocatedPartsCountPtr)>0)
        {
          // Copy previous parts
          memcpy(newParts,*partsPtr,allocatedSize);

          //Dealloc previous parts
          NSZoneFree(NSDefaultMallocZone(),*partsPtr);
        };

      // Zeroing new parts
      memset(newParts+(*allocatedPartsCountPtr),0,
             allocSize-allocatedSize);

      *allocatedPartsCountPtr=allocPartsCount;
      *partsPtr=newParts;
      NSDebugFLLog(@"GSWElementID",
                   @"==> *partsPtr=%p *allocatedPartsCountPtr=%d",
                   *partsPtr,*allocatedPartsCountPtr);
    };
};

//--------------------------------------------------------------------
/** Returns a elementID **/
+(GSWElementID*)elementID
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
/** Returns elementID initialized with 'string' **/
+(GSWElementID*)elementIDWithString:(NSString*)string
{
  return [[[self alloc]initWithString:string]autorelease];
};

//--------------------------------------------------------------------
-(id)init
{
  return [self initWithPartsCountCapacity:
                 GSWElementID_DefaultElementPartsCount];
};

//--------------------------------------------------------------------
/** Base initializer
partsCount is the number of parts to allocate
**/
-(id)initWithPartsCountCapacity:(int)partsCount
{
  if ((self=[super init]))
    {
      _deleteElementsFromIndexIMP=[self methodForSelector:deleteElementsFromIndexSelector];
      _buildElementPartsIMP=[self methodForSelector:buildElementPartsSelector];
      if (partsCount>0)
        {
          GSWElementIDRealloc(&_parts,&_allocatedPartsCount,partsCount);
        };
    };
  return self;
};

//--------------------------------------------------------------------
/** Initialize from 'string' elementID
**/
-(id)initWithString:(NSString*)string
{  
  int partsCount=0;
  unichar* stringChars=NULL;
  int length=0;
  unichar* ptr=NULL;
  unichar* stringEndPtr=NULL;

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWElementID",@"string=%@",string);

  length=[string length];
  if (length>0)
    {
      stringChars=NSZoneMalloc(NSDefaultMallocZone(),(length+1)*sizeof(unichar));
      NSAssert1(stringChars,@"Can't allocate memeory for string of length %d",length);

      [string getCharacters:stringChars];
      stringChars[length]=(unichar)0;

      ptr=stringChars;
      stringEndPtr=stringChars+length;

      partsCount=1;
      while(ptr<stringEndPtr)
        {
          if (*ptr=='.')
            partsCount++;
          ptr++;
        };

      NSDebugMLLog(@"GSWElementID",@"partsCount=%d",partsCount);
      partsCount+=16; // keeps space for extensions
    }
  else
    partsCount=GSWElementID_DefaultElementPartsCount;

  NSDebugMLLog(@"GSWElementID",@"partsCount=%d",partsCount);

  if ((self=[self initWithPartsCountCapacity:partsCount]))
    {
      if (stringChars)
        {
          GSWElementIDPart* part=_parts;
          unichar* startPartPtr=NULL;
          unichar* endPartPtr=NULL;          
          startPartPtr=stringChars;

          // For each part, we'll find start and end of part, if it is all numeric 
          // or a string (+numeric part).
          while(startPartPtr<stringEndPtr)
            {
              int number=0; // result numeric part
              BOOL isAllNumeric=YES; // is entirely numeric ?
              unichar* numericIndexPtr=NULL; // end numeric part pointer
              
              ptr=startPartPtr;
              endPartPtr=NULL; // end part pointer

              NSDebugMLLog(@"GSWElementID",@"stringChars=%p stringEndPtr=%p length=%d startPartPtr=%p",
                           stringChars,stringEndPtr,length,startPartPtr);
              NSDebugMLLog(@"GSWElementID",@"Starting partString=%@",
                           [NSString stringWithCharacters:startPartPtr
                                     length:stringEndPtr-startPartPtr]);

              while(ptr<stringEndPtr)
                {
                  // End of part ?
                  if (*ptr=='.')
                    {
                      endPartPtr=ptr-1;
                      break;
                    }                  
                  else if (isdigit(*ptr)) // Is digit ?
                    {
                      // (re-)start calculating numeric part
                      if (!isAllNumeric && !numericIndexPtr)
                        numericIndexPtr=ptr;

                      number=number*10+(*ptr-'0');
                    }
                  else // Not a digit ?
                    {
                      //Stop numeric calculation
                      isAllNumeric=NO;
                      numericIndexPtr=NULL;
                    };
                  ptr++;
                };

              // no '.' found ==> last part
              if (!endPartPtr)
                endPartPtr=stringEndPtr-1;

              NSDebugMLLog(@"GSWElementID",@"startPartPtr=%p endPartPtr=%p",
                           startPartPtr,endPartPtr);

              NSDebugMLLog(@"GSWElementID",@"part=%@ isAllNumeric=%d numericIndexPtr=%p number=%d",
                           [NSString stringWithCharacters:startPartPtr
                                     length:endPartPtr-startPartPtr+1],
                           isAllNumeric,numericIndexPtr,number);
              
              // Entirely numeric ?
              if (isAllNumeric)
                {
                  // number is calculated
                  part->_number=number;
                }
              else
                {
                  // Numeric part (if any) is calculated
                  if (numericIndexPtr)
                    part->_number=number;
                  else
                    numericIndexPtr=stringEndPtr+1;
                  
                  ASSIGN(part->_string,([NSString stringWithCharacters:startPartPtr
                                                  length:(numericIndexPtr-1)-startPartPtr+1]));
                };
              //We could also build part elementIDString but I'm not sure it's interesting as 
              //initializing GSWElementID from string is mainly to be used for 'statics' elementIDs
              //Assigning _elementIDString at the end should be sufficient.
              NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
                           _partsCount,GSWElementIDPartDescription(part));
              
              _partsCount++;
              part++;
              startPartPtr=endPartPtr+2;//skip dot
            };
        };
    };      
  NSDebugMLLog(@"GSWElementID",@"string: %@ => elementIDString=%@",
              string,[self elementIDString]);
  ASSIGN(_elementIDString,string);

  LOGObjectFnStop();

  return self;
};

//--------------------------------------------------------------------
/** dealloc object **/
-(void)dealloc
{
  LOGObjectFnStart();

  GSWLogAssertGood(self);

  if (_allocatedPartsCount>0)
    {
      int i=0;
      GSWElementIDPart* part=NULL;
      // allocated parts even if not used may keey _elementIDString
      for(i=0,part=_parts;i<_allocatedPartsCount;i++,part++) 
        {
          DESTROY(part->_string);
          DESTROY(part->_elementIDString);
        };
      NSZoneFree(NSDefaultMallocZone(),_parts);
    };

  DESTROY(_tmpString);
  DESTROY(_elementIDString);
          
  DESTROY(_isSearchOverLastSenderIDString);
  DESTROY(_isSearchOverLastSenderID);

  [super dealloc];
  GSWLogMemC("GSWElementID end of dealloc");
};

//--------------------------------------------------------------------
/** Init from coder **/
-(id)initWithCoder:(NSCoder*)decoder
{
  NSString* aString=nil;
  [decoder decodeValueOfObjCType:@encode(id)
          at:&aString];
  return [self initWithString:aString];
};

//--------------------------------------------------------------------
/** Encode into coder **/
-(void)encodeWithCoder:(NSCoder*)encoder
{
  NSString* aString=[self elementIDString];
  [encoder encodeValueOfObjCType:@encode(id)
           at:&aString];
};

//--------------------------------------------------------------------
/** Returns a copy **/
-(id)copyWithZone:(NSZone*)zone
{
  int i=0;
  GSWElementID* clone = [[[self class] alloc]initWithPartsCountCapacity:_partsCount+16];

  NSAssert(clone,@"No clone of GSWElementID");

  for(i=0;i<_partsCount;i++)
    {      
      GSWElementIDPart* selfPart=_parts+i;
      GSWElementIDPart* clonePart=clone->_parts+i;
      ASSIGN(clonePart->_string,selfPart->_string);
      clonePart->_number=selfPart->_number;
      //Should we copy part caches ? I don't think is interesting
    };

  //_builtPartCount stay to 0;

  // Copy pre-built _elementIDString if any
  ASSIGN(clone->_elementIDString,_elementIDString);

  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [self elementIDString];
};

//--------------------------------------------------------------------
/** Returns YES if we should stop search (if self is greater than senderID)
For better performences, senderID should be an immutable string
**/
-(BOOL)isSearchOverForSenderID:(NSString*)senderID
                      onParent:(BOOL)onParentFlag
{
  BOOL over=NO;

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWElementID",@"senderID=%@",senderID);
  NSDebugMLLog(@"GSWElementID",@"onParentFlag=%d",onParentFlag);

  if (senderID == nil)
    [NSException raise:NSInvalidArgumentException
                 format:@"compare with nil"];
  else
    {
      int count=0;
      int i=0;
      GSWElementID* senderElementID=nil;
      GSWElementIDPart* selfElementPart=NULL;
      GSWElementIDPart* senderElementPart=NULL;

      //We can make a == test because we cache only immutable senderIDs
      if (senderID==_isSearchOverLastSenderIDString)
        senderElementID=_isSearchOverLastSenderID;
      else
        {
          senderElementID=[[self class]elementIDWithString:senderID];
          NSDebugMLLog(@"GSWElementID",@"senderElementID=%@",senderElementID);

          //Cache it if it is not mutable
          if ([senderID isKindOfClass:[NSMutableString class]])
            {
              NSWarnLog(@"Performances: senderID passed to -isSearchOverForSenderID: is a mutable string");
            }
          else
            {
              ASSIGN(_isSearchOverLastSenderIDString,senderID);
              ASSIGN(_isSearchOverLastSenderID,senderElementID);
            };          
        };

      count=min((onParentFlag ? _partsCount-1 : _partsCount),senderElementID->_partsCount);
      NSDebugMLog(@"count=%d",count);
      for(i=0,selfElementPart=_parts,senderElementPart=senderElementID->_parts;
          i<count && !over;
          i++,selfElementPart++,senderElementPart++)
        {
          NSDebugMLLog(@"GSWElementID",@"selfElementPart #%d: %@",
                       i,GSWElementIDPartDescription(selfElementPart));

          NSDebugMLLog(@"GSWElementID",@"senderElementPart #%d: %@",
                       i,GSWElementIDPartDescription(senderElementPart));

          if (selfElementPart->_string)
            {
              if (senderElementPart->_string) // string & string
                {
                  NSComparisonResult cResult=[selfElementPart->_string compare:senderElementPart->_string];
                  if (cResult==NSOrderedDescending)
                    over=YES;
                  else if (cResult==NSOrderedSame)
                    {
                      if (selfElementPart->_number>senderElementPart->_number)
                        over=YES;
                      else if (selfElementPart->_number<senderElementPart->_number) // Not over => break
                        break;
                      // else continue
                    }
                  else //NSOrderedAscending: not over => break
                    break;
                }
              else // string and num
                {
                  //Shouldn't happen logically as the root of 2 elementIDs should be the same
                  //Anyway, we consider not over and break here
                };
            }
          else
            {
              if (senderElementPart->_string) // num & string
                {
                  //Shouldn't happen logically as the root of 2 elementIDs should be the same
                  //Anyway, we consider not over and break here
                }
              else // num & num
                {
                  if (selfElementPart->_number>senderElementPart->_number)
                    over=YES;
                  else if (selfElementPart->_number<senderElementPart->_number)
                    break; //not over
                  // else continue
                };
            };
          NSDebugMLLog(@"GSWElementID",@"Part #%d selfElementPart=%@ senderIDElementPart=%@ => over=%d",
                       i,
                       GSWElementIDPartDescription(selfElementPart),
                       GSWElementIDPartDescription(senderElementPart),
                       over);
        };
      NSDebugMLLog(@"GSWElementID",@"self=%@ senderID=%@ => over=%d",
                   [self elementIDString],senderID,over);
    };

  LOGObjectFnStop();

  return over;
}

//--------------------------------------------------------------------
/** Returns YES if we should stop search (if self is greater than senderID)
For better performences, senderID should be an immutable string
**/
-(BOOL)isSearchOverForSenderID:(NSString*)senderID
{
  //NSLog(@"ELEMENTID: [elementID isSearchOverForSenderID:@\"%@\"];",senderID);
  return [self isSearchOverForSenderID:senderID
               onParent:NO];
};

//--------------------------------------------------------------------
/** Returns YES if we should stop search (if self is greater than senderID)
For better performences, senderID should be an immutable string
**/
-(BOOL)isParentSearchOverForSenderID:(NSString*)senderID
{
  //NSLog(@"ELEMENTID: [elementID isParentSearchOverForSenderID:@\"%@\"];",senderID);
  return [self isSearchOverForSenderID:senderID
               onParent:YES];
};

//--------------------------------------------------------------------
/** Build parts _elementIDString **/
-(void)_buildElementParts
{
  static NSString* preBuiltDotPlusNum[] = {
    @".0", @".1", @".2", @".3", @".4", @".5", @".6", @".7", @".8", @".9", 
    @".10", @".11", @".12", @".13", @".14", @".15", @".16", @".17", @".18", @".19", 
    @".20", @".21", @".22", @".23", @".24", @".25", @".26", @".27", @".28", @".29", 
    @".30", @".31", @".32", @".33", @".34", @".35", @".36", @".37", @".38", @".39", 
    @".40", @".41", @".42", @".43", @".44", @".45", @".46", @".47", @".48", @".49", 
    @".50", @".51", @".52", @".53", @".54", @".55", @".56", @".57", @".58", @".59", 
    @".60", @".61", @".62", @".63", @".64", @".65", @".66", @".67", @".68", @".69" };
  static int preBuiltDotPlusNumCount = sizeof(preBuiltDotPlusNum)/sizeof(NSString*);

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWElementID",@"_partsCount=%d _builtPartCount=%d",
              _partsCount,_builtPartCount);

  NSAssert1(_builtPartCount>=0,@"_builtPartCount=%d",_builtPartCount);

  if (_partsCount>0)
    {
      GSWElementIDPart* part=NULL;
      if (_builtPartCount<_partsCount)
        {
          int i=0;
          
          NSDebugMLLog(@"GSWElementID",@"_tmpString=%@",_tmpString);
          // No working string created ? 
          if (!_tmpString)
            {
              // Create working string and cache -appendString: IMP
              _tmpString=(NSMutableString*)[NSMutableString new]; //Retained !
              _tmpString_appendStringIMP=[_tmpString methodForSelector:appendStringSelector];
              _tmpString_setStringIMP=[_tmpString methodForSelector:setStringSelector];
            };
          
          // Start from previous built element if one otherwise, start from empty string
          part=_parts+_builtPartCount-1;
          (*_tmpString_setStringIMP)(_tmpString,appendStringSelector,
                                     (_builtPartCount>0 ?
                                      (NSString*)(part->_elementIDString) : (NSString*)@""));
          
          NSDebugMLLog(@"GSWElementID",@"_tmpString=%@",_tmpString);
          for(i=_builtPartCount,part=_parts+_builtPartCount;i<_partsCount;i++,part++)
            {
              NSDebugMLLog(@"GSWElementID",@"Part#%d _parts=%p part=%p",
                           i,_parts,part);

              NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
                           i,GSWElementIDPartDescription(part));

              if (part->_string)
                {
                  if (i>0)
                    {
                      (*_tmpString_appendStringIMP)(_tmpString,
                                                    appendStringSelector,@".");
                    };

                  (*_tmpString_appendStringIMP)(_tmpString,
                                                appendStringSelector,part->_string);
                  if (part->_number>0)
                    {
                      (*_tmpString_appendStringIMP)(_tmpString,
                                                    appendStringSelector,
                                                    GSWIntToNSString(part->_number));
                    };
                }
              else
                {
                  if (i>0)
                    {
                      if (part->_number<preBuiltDotPlusNumCount)
                        {
                          // Save a appendString :-)
                          (*_tmpString_appendStringIMP)(_tmpString,
                                                        appendStringSelector,
                                                        preBuiltDotPlusNum[part->_number]);
                        }
                      else
                        {
                          (*_tmpString_appendStringIMP)(_tmpString,
                                                        appendStringSelector,
                                                        @".");                  
                          
                          (*_tmpString_appendStringIMP)(_tmpString,
                                                        appendStringSelector,
                                                        GSWIntToNSString(part->_number));
                        };
                    }
                  else
                    {
                      (*_tmpString_appendStringIMP)(_tmpString,
                                                    appendStringSelector,
                                                    GSWIntToNSString(part->_number));
                    };
                };

              NSDebugMLLog(@"GSWElementID",@"_tmpString=%@",_tmpString);
              NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
                           i,GSWElementIDPartDescription(part));

              if (part->_elementIDString)
                {
                  (*part->_elementIDString_setStringIMP)(part->_elementIDString,
                                                         setStringSelector,
                                                         _tmpString);
                }
              else
                {
                  part->_elementIDString=[_tmpString mutableCopy]; //Retained !
                  part->_elementIDString_setStringIMP=[part->_elementIDString 
                                                           methodForSelector:setStringSelector];
                };
              NSDebugMLLog(@"GSWElementID",@"part->_elementIDString=%@",part->_elementIDString);
            };
          _builtPartCount=_partsCount;
          NSDebugMLLog(@"GSWElementID",@"_builtPartCount=%d",_builtPartCount);
        };  

      part=_parts+_partsCount-1;
      ASSIGN(_elementIDString,([NSString stringWithString:part->_elementIDString]));

      NSDebugMLLog(@"GSWElementID",@"_elementIDString=%@",_elementIDString);
    };
  NSDebugMLLog(@"GSWElementID",@"_builtPartCount=%d _partsCount=%d",_builtPartCount,_partsCount);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Returns elementID string representation or empty string if there's not 
elements **/
-(NSString*)elementIDString
{
  NSString* elementIDString=@"";

  //NSLog(@"ELEMENTID: [elementID elementIDString];");

  NSDebugMLLog(@"GSWElementID",@"_partsCount=%d",_partsCount);
  if (_partsCount>0)
    {
      NSDebugMLLog(@"GSWElementID",@"_elementIDString=%@",_elementIDString);
      if (!_elementIDString) // Not alreday built ?
        (*_buildElementPartsIMP)(self,buildElementPartsSelector);
      elementIDString=_elementIDString;
      AUTORELEASE(RETAIN(elementIDString));
    };
  NSDebugMLLog(@"GSWElementID",@"elementIDString=%@",elementIDString);

  return elementIDString;
}

//--------------------------------------------------------------------
/** Deletes element parts starting at fromIndex. **/
-(void)_deleteElementsFromIndex:(int)fromIndex
{
  int i=0;
  GSWElementIDPart* part=NULL;

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWElementID",@"fromIndex=%d _partsCount=%d _builtPartCount=%d",
               fromIndex,_partsCount,_builtPartCount);

  NSAssert1(fromIndex>=0,@"fromIndex (%d) <0",
            fromIndex);
  NSAssert2(fromIndex<_partsCount,@"fromIndex (%d) >= _partsCount (%d)",
            fromIndex,_partsCount);

  for(i=fromIndex,part=_parts+fromIndex;i<_partsCount;i++,part++)
    {
      DESTROY(part->_string);
      part->_number=0;
    };

  // update cache state information
  if (_builtPartCount>fromIndex)
    _builtPartCount=fromIndex;
  DESTROY(_elementIDString);      

  _partsCount=fromIndex;

  NSDebugMLLog(@"GSWElementID",@"==>fromIndex=%d _partsCount=%d _builtPartCount=%d",
               fromIndex,_partsCount,_builtPartCount);

  LOGObjectFnStop();
}

  
//--------------------------------------------------------------------
/** empties elementID **/
-(void)deleteAllElementIDComponents
{
  LOGObjectFnStart();

  //NSLog(@"ELEMENTID: [elementID deleteAllElementIDComponents];");

  if (_partsCount>0)
    (*_deleteElementsFromIndexIMP)(self,deleteElementsFromIndexSelector,0);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Deletes last elementID part **/
-(void)deleteLastElementIDComponent
{
  LOGObjectFnStart();

  //NSLog(@"ELEMENTID: [elementID deleteLastElementIDComponent];");

  if (_partsCount>0)
    (*_deleteElementsFromIndexIMP)(self,deleteElementsFromIndexSelector,_partsCount-1);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Increments last elementID part **/
-(void)incrementLastElementIDComponent
{
  LOGObjectFnStart();

  //NSLog(@"ELEMENTID: [elementID incrementLastElementIDComponent];");

  if (_partsCount<1)
    {
      NSWarnLog(@"Can't incrementLastElementIDComponent on an empty elementID");
    }
  else
    {
      GSWElementIDPart* part=NULL;

      NSDebugMLLog(@"GSWElementID",@"_partsCount=%d _builtPartCount=%d",
                   _partsCount,_builtPartCount);

      // Update part number
      part=_parts+_partsCount-1;
      part->_number++;
      NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
                   _partsCount-1,GSWElementIDPartDescription(part));

      // update cache state information
      if (_builtPartCount>=_partsCount)
        _builtPartCount=_partsCount-1;
      DESTROY(_elementIDString);      

      NSDebugMLLog(@"GSWElementID",@"==> _partsCount=%d _builtPartCount=%d",
                   _partsCount,_builtPartCount);
    };
};
  
//--------------------------------------------------------------------
/** Append zero element ID after last elementID part **/
-(void)appendZeroElementIDComponent
{
  GSWElementIDPart* part=NULL;

  LOGObjectFnStart();

  //NSLog(@"ELEMENTID: [elementID appendZeroElementIDComponent];");

  NSDebugMLLog(@"GSWElementID",@"_partsCount=%d _builtPartCount=%d",
               _partsCount,_builtPartCount);

  if (_partsCount>=_allocatedPartsCount)
    GSWElementIDRealloc(&_parts,&_allocatedPartsCount,
                        _allocatedPartsCount+GSWElementID_DefaultElementPartsCount);

  // Set to new part
  part=_parts+_partsCount;
  part->_number=0;
  NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
               _partsCount,GSWElementIDPartDescription(part));

  // update cache state information
  DESTROY(_elementIDString);

  // Increments parts count
  _partsCount++;

  NSDebugMLLog(@"GSWElementID",@"==> _partsCount=%d _builtPartCount=%d",
               _partsCount,_builtPartCount);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Append 'element' element ID after last elementID part 
You should avoid element ending with digits.
**/
-(void)appendElementIDComponent:(NSString*)element
{
  int elementLength=0;
  GSWElementIDPart* part=NULL;

  LOGObjectFnStart();

  //NSLog(@"ELEMENTID: [elementID appendElementIDComponent:@\"%@\"];",element);

  elementLength=[element length];
  
  if (elementLength==0)
    {
      NSWarnLog(@"append empty empty element");
    }
  else
    {
      if (isdigit([element characterAtIndex:elementLength-1]))
        {
          NSWarnLog(@"You'll may get problems if you use anElementID which ends with digit(s) like you do: '%@'",
                    element);
        };
    }

  NSDebugMLLog(@"GSWElementID",@"_partsCount=%d _builtPartCount=%d element=%@",
               _partsCount,_builtPartCount,element);

  if (_partsCount>=_allocatedPartsCount)
    GSWElementIDRealloc(&_parts,&_allocatedPartsCount,
                        _allocatedPartsCount+GSWElementID_DefaultElementPartsCount);

  // Set to new part
  part=_parts+_partsCount;
  part->_number=0;
  ASSIGNCOPY(part->_string,element);

  NSDebugMLLog(@"GSWElementID",@"Part #%d: %@",
               _partsCount,GSWElementIDPartDescription(part));

  // update cache state information
  DESTROY(_elementIDString);
  
  // Increments parts count
  _partsCount++;

  NSDebugMLLog(@"GSWElementID",@"==> _partsCount=%d _builtPartCount=%d",
               _partsCount,_builtPartCount);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
/** Returns parent element ID **/
-(NSString*)parentElementIDString
{
  NSString* elementIDString=@"";
  if (_partsCount>1)
    {
      GSWElementIDPart* part=NULL;
      if (_builtPartCount<(_partsCount-1))
          (*_buildElementPartsIMP)(self,buildElementPartsSelector);
      
      part=_parts+_partsCount-2;
      elementIDString=[NSString stringWithString:part->_elementIDString];
    };
  return elementIDString;
};

//--------------------------------------------------------------------
//NDFN
/** returns number of element ID parts **/
-(int)elementsCount
{
  return _partsCount;
};

@end

