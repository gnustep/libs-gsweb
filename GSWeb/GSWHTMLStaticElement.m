/** GSWHTMLStaticElement.m - <title>GSWeb: Class GSWHTMLStaticElement</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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
#include <GNUstepBase/NSObject+GNUstepBase.h>

/*

In WO 5 this class is WODynamicGroup I think.
In WO 4.5 WOHTMLStaticElement.

*/


static SEL objectAtIndexSEL = NULL;
static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;
static Class GSWHTMLBareStringClass = Nil;

//====================================================================
@implementation GSWHTMLStaticElement

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWHTMLStaticElement class])
    {
      standardClass=[GSWHTMLStaticElement class];
      GSWHTMLBareStringClass = [GSWHTMLBareString class];
      objectAtIndexSEL=@selector(objectAtIndex:);

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)anElementName
	 attributeDictionary:(NSDictionary*)aAttributeAssociationsList
             contentElements:(NSArray*)anElementsArray
{
  //OK

  if ((self=[super init]))
    {
      NSMutableArray* attributeAssociationsValues=[NSMutableArray array];
      NSMutableArray* tmpHtmlBareStrings=[NSMutableArray array];
      NSMutableData* tmpElementsMap=[[NSMutableData new]autorelease];
      ASSIGN(_elementName,anElementName);//??
      if (anElementName)
        {
          NSEnumerator* attributesKeyEnum=nil;
          id key=nil;
          [tmpHtmlBareStrings addObject:[@"<" stringByAppendingString:NSStringWithObject(anElementName)]];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];

          attributesKeyEnum= [aAttributeAssociationsList keyEnumerator];

          while ((key = [attributesKeyEnum nextObject]))
            {
              id association=[aAttributeAssociationsList objectForKey:key];
              id associationValue=[association valueInComponent:nil];

              [tmpHtmlBareStrings addObject:[@" " stringByAppendingString:NSStringWithObject(key)]];
              [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                              length:1];
              if (associationValue)
                {
                  [tmpHtmlBareStrings addObject:[NSString stringWithString:@"="]];
                  [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                                  length:1];
                  [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@"\"%@\"",associationValue]];
                  [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                                  length:1];
                }
              else
                {
                  //TODO So what next ?
                  [attributeAssociationsValues addObject:association];
                  [tmpElementsMap appendBytes:&ElementsMap_attributeElement
                                  length:1];
                  
                };
            };
          [tmpHtmlBareStrings addObject:@">"];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
        };
      if (anElementsArray)
        {
          int elementsN=[anElementsArray count];
          for(;elementsN>0;elementsN--)
            [tmpElementsMap appendBytes:&ElementsMap_dynamicElement
                            length:1];
          if (anElementName)
            {
              [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
                                                      anElementName]];
              [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                              length:1];
            };
        };
      
      [self _initWithElementsMap:tmpElementsMap
            htmlBareStrings:tmpHtmlBareStrings
            dynamicChildren:anElementsArray];
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)anElementName
  attributeString:(NSString*)attributeString
  contentElements:(NSArray*)anElementsArray
{

  if ((self=[super init]))
    {
      NSMutableArray* tmpHtmlBareStrings=[NSMutableArray array];
      NSMutableData* tmpElementsMap=[[NSMutableData new]autorelease];
      ASSIGN(_elementName,anElementName);//??

      if (anElementName)
        {
          [tmpHtmlBareStrings addObject:[@"<" stringByAppendingString:NSStringWithObject(anElementName)]];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
          [tmpHtmlBareStrings addObject:attributeString];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
          [tmpHtmlBareStrings addObject:@">"];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
        };
      if (anElementsArray)
        {
          int elementsN=[anElementsArray count];
          for(;elementsN>0;elementsN--)
            [tmpElementsMap appendBytes:&ElementsMap_dynamicElement
                            length:1];
          if (anElementName)
            {
              [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
                                                      anElementName]];
              [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                              length:1];
            };
        };
      [self _initWithElementsMap:tmpElementsMap
            htmlBareStrings:tmpHtmlBareStrings
            dynamicChildren:anElementsArray];	  
    };
  return self;
};

//--------------------------------------------------------------------
-(id)_initWithElementsMap:(NSData*)tmpElementsMap
          htmlBareStrings:(NSArray*)tmpHtmlBareStrings
          dynamicChildren:(NSArray*)aDynamicChildrensArray
{
  BOOL compactHTMLTags=NO;

  compactHTMLTags=[self compactHTMLTags];
  //OK
  if (compactHTMLTags)
    {
      int elementN=0;
      while(elementN<[tmpElementsMap length] && ((BYTE*)[tmpElementsMap bytes])[elementN]==ElementsMap_htmlBareString)
        elementN++;
      [self _setEndOfHTMLTag:elementN];
      if (elementN>0)
        {
          int rmStringN=0;
          int tmpHtmlBareStringsCount=0;
          NSMutableArray* rmStrings=[NSMutableArray array];
          NSMutableString* rmString=[[NSMutableString new] autorelease];
          NSMutableData* tmpElementsMap=[[NSMutableData new] autorelease];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
          if ([tmpElementsMap length]>elementN)
            [tmpElementsMap appendData:
                              [tmpElementsMap subdataWithRange:
                                                NSMakeRange(elementN,
                                                            [tmpElementsMap length]-elementN)]];
          tmpElementsMap=tmpElementsMap;
          for(rmStringN=0;rmStringN<elementN;rmStringN++)
            {
              [rmString appendString:[tmpHtmlBareStrings objectAtIndex:rmStringN]];
            };
          [rmStrings addObject:rmString];

          tmpHtmlBareStringsCount=[tmpHtmlBareStrings count];
          for(rmStringN=elementN;rmStringN<tmpHtmlBareStringsCount;rmStringN++)
            {
              [rmStrings addObject:[tmpHtmlBareStrings objectAtIndex:rmStringN]];
            };
          tmpHtmlBareStrings=rmStrings;
        };
    };
  ASSIGN(_htmlBareStrings,tmpHtmlBareStrings);
  ASSIGN(_elementsMap,tmpElementsMap);
  ASSIGN(_dynamicChildren,aDynamicChildrensArray);

  return self;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return _elementName;
};

//--------------------------------------------------------------------
-(NSArray*)dynamicChildren
{
  return _dynamicChildren;
};

// to be compatible with GSWDynamicGroup.
// do we have to add htmlBareStrings also? dw
-(NSArray*) childrenElements
{
  return _dynamicChildren;
};

//--------------------------------------------------------------------
-(NSArray*)htmlBareStrings
{
  return _htmlBareStrings;
};

//--------------------------------------------------------------------
-(NSData*)elementsMap
{
  return _elementsMap;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_elementsMap);
  DESTROY(_htmlBareStrings);
  DESTROY(_dynamicChildren);
  DESTROY(_elementName);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)_setEndOfHTMLTag:(unsigned int)unknown
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------

- (BOOL) hasChildrenElements
{
  return ([_elementsMap length] > 0);
}

-(NSString*)description
{

  return [NSString stringWithFormat:@"<%@ %p elementName:%@ htmlBareStrings:%@ dynamicChildren:%@ elementsMap:%@>",
				   [self class],
				   (void*)self, _elementName, _htmlBareStrings, _dynamicChildren,
				   _elementsMap];
};


//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
  int length=0;
  //GSWRequest* request=[aContext request];
  //not used BOOL isFromClientComponent=[request isFromClientComponent]; //bis repetitam
//  GSWStartElement(aContext);
//  GSWSaveAppendToResponseElementID(aContext);

  length=[_elementsMap length];
  [aContext appendZeroElementIDComponent];
  
  if (length>0) {
   [self appendToResponse:response
         inContext:aContext
         elementsFromIndex:0
         toIndex:length-1];
  };

 [aContext deleteLastElementIDComponent];
    
//  GSWAssertIsElementID(aContext);
//  GSWStopElement(aContext);
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
      elementsFromIndex:(unsigned int)fromIndex
                toIndex:(unsigned int)toIndex
{
  IMP htmlBareStringsObjectAtIndexIMP=NULL;
  IMP objectAtIndexIMP = NULL;
  NSArray* aDynamicChildrensArray=[self dynamicChildren];//call dynamicChildren //GSWTextField: nil
  int elementN=0;
  const BYTE* elements=[_elementsMap bytes];
  BYTE element=0;
  int elementsN[3]={0,0,0};

  NSAssert2(fromIndex<[_elementsMap length],@"fromIndex out of range:%u (length=%d)",
            fromIndex,[_elementsMap length]);
  NSAssert2(toIndex<[_elementsMap length],@"toIndex out of range:%u (length=%d)",
            toIndex,[_elementsMap length]);
  NSAssert2(fromIndex<=toIndex,@"fromIndex>toIndex %u %u ",
            fromIndex,toIndex);

  for(elementN=0;elementN<=toIndex;elementN++)
    {
      element=(BYTE)elements[elementN];
      if (element==ElementsMap_htmlBareString)
        {
          if (elementN>=fromIndex)
            {
              if (!htmlBareStringsObjectAtIndexIMP)
                htmlBareStringsObjectAtIndexIMP = [_htmlBareStrings methodForSelector:objectAtIndexSEL];

              GSWResponse_appendContentString(aResponse,
                                              ((*htmlBareStringsObjectAtIndexIMP)(_htmlBareStrings,
                                                                                 objectAtIndexSEL,
                                                                                 elementsN[0])));
            };

          elementsN[0]++;
        }
      else if (element==ElementsMap_dynamicElement)
        {
          if (elementN>=fromIndex)
            {
              if (!objectAtIndexIMP)
                objectAtIndexIMP = [aDynamicChildrensArray methodForSelector:objectAtIndexSEL];

              [(*objectAtIndexIMP)(aDynamicChildrensArray,objectAtIndexSEL,elementsN[1])
                                  appendToResponse:aResponse
                                  inContext:aContext];

              GSWContext_incrementLastElementIDComponent(aContext);

            };
          elementsN[1]++;
        }
      else if (element==ElementsMap_attributeElement)
        {
          //TODO
          elementsN[2]++;
        };
    };
  GSWStopElement(aContext);
};

//--------------------------------------------------------------------
  
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  BOOL searchIsOver=NO;
  NSString* senderID=nil;
  int length=0;


  senderID=GSWContext_senderID(aContext);

  length=[_elementsMap length];

  if ([self hasChildrenElements])  {
      IMP objectAtIndexIMP = NULL;
      NSArray* aDynamicChildrensArray=[self dynamicChildren];
      const BYTE* elements=[_elementsMap bytes];
      BYTE elementIndic=0;
      int elementsN[3]={0,0,0};
      int elementN=0;

id currentEl = nil;

      [aContext appendZeroElementIDComponent];
      
      for(elementN=0;!element && !searchIsOver && elementN<length;elementN++)
        {
          elementIndic=(BYTE)elements[elementN];
          if (elementIndic==ElementsMap_htmlBareString)
            elementsN[0]++;
          else if (elementIndic==ElementsMap_dynamicElement)
            {
              if (!objectAtIndexIMP)
                objectAtIndexIMP = [aDynamicChildrensArray methodForSelector:objectAtIndexSEL];

                 currentEl = (*objectAtIndexIMP)(aDynamicChildrensArray,objectAtIndexSEL,elementsN[1]);
                 if ([currentEl class] != GSWHTMLBareStringClass) {

                   element=[currentEl invokeActionForRequest:request
                                                   inContext:aContext];
     
                   NSAssert3(!element || [element isKindOfClass:[GSWElement class]],
                             @"From: %@, Element is a %@ not a GSWElement: %@",
                             [aDynamicChildrensArray objectAtIndex:elementsN[1]],
                             [element class],
                             element);
                 }
// TODO: check if that is right.                 
//              if (![aContext _wasFormSubmitted] && GSWContext_isSenderIDSearchOver(aContext))
              if (![aContext _wasFormSubmitted] && (element))
                {
                  searchIsOver=YES;
                };

              GSWContext_incrementLastElementIDComponent(aContext);

              elementsN[1]++;
            }
          else if (elementIndic==ElementsMap_attributeElement)
            {
              elementsN[2]++;
            };
        };
        [aContext deleteLastElementIDComponent];
    };

  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  int length=0;

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  length=[_elementsMap length];
  if ([self hasChildrenElements])  {

      IMP objectAtIndexIMP = NULL;
      int elementN=0;
      NSArray* aDynamicChildrensArray=[self dynamicChildren];
      const BYTE* elements=[_elementsMap bytes];
      BYTE elementIndic=0;
      int elementsN[3]={0,0,0};

      [aContext appendZeroElementIDComponent];

      for(elementN=0;elementN<length;elementN++)
        {
          elementIndic=(BYTE)elements[elementN];
          if (elementIndic==ElementsMap_htmlBareString)
            elementsN[0]++;
          else if (elementIndic==ElementsMap_dynamicElement)
            {
              if (!objectAtIndexIMP)
                objectAtIndexIMP = [aDynamicChildrensArray methodForSelector:objectAtIndexSEL];

              [(*objectAtIndexIMP)(aDynamicChildrensArray,objectAtIndexSEL,elementsN[1])
                                  takeValuesFromRequest:request
                                  inContext:aContext];

              GSWContext_incrementLastElementIDComponent(aContext);

              elementsN[1]++;
            }
          else if (elementIndic==ElementsMap_attributeElement)
            {
              elementsN[2]++;
            };
        };
      [aContext deleteLastElementIDComponent];
    };
  GSWAssertIsElementID(aContext);
  GSWStopElement(aContext);
};


//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)canBeFlattenedAtInitialization
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(BOOL)charactersNeedingQuotes
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(void)addURLAttribute:(id)attribute
       forElementNamed:(NSString*)name
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
+(id)urlsForElementNamed:(NSString*)name
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(NSDictionary*)attributeDictionaryForString:(NSString*)string
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(NSString*)stringForAttributeDictionary:(NSDictionary*)attributeDictionary
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name
              attributeString:(NSString*)attributeString
              contentElements:(NSArray*)elements
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name
          attributeDictionary:(NSDictionary*)attributeDictionary
              contentElements:(NSArray*)elements
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

+(Class)_elementClassForName:(NSString*)name
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

+(void)setElementClass:(Class)class
               forName:(NSString*)name
{
  [self notImplemented: _cmd];	//TODOFN
};

+(GSWElement*)_theEmptyElement
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

@end 
