/** GSWHTMLStaticElement.m - <title>GSWeb: Class GSWHTMLStaticElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWHTMLStaticElement

//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)anElementName
	 attributeDictionary:(NSDictionary*)aAttributeAssociationsList
             contentElements:(NSArray*)anElementsArray
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"anElementName=%@ aAttributeAssociationsList:%@ anElementsArray=%@",
               anElementName,
               aAttributeAssociationsList,
               anElementsArray);
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
          [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
                                                  anElementName]];
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];

          attributesKeyEnum= [aAttributeAssociationsList keyEnumerator];
          NSDebugMLLog(@"gswdync",@"attributesKeyEnum=%@ aAttributeAssociationsList=%@",
                       attributesKeyEnum,aAttributeAssociationsList);
          while ((key = [attributesKeyEnum nextObject]))
            {
              id association=[aAttributeAssociationsList objectForKey:key];
              id associationValue=[association valueInComponent:nil];
              NSDebugMLLog(@"gswdync",@"association=%@ associationValue=%@",
                           association,associationValue);
              [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@" %@",key]];
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
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)anElementName
		 attributeString:(NSString*)attributeString
		 contentElements:(NSArray*)anElementsArray
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"anElementName=%@ attributeString:%@ anElementsArray=%@",
		anElementName,
		attributeString,
		anElementsArray);
  if ((self=[super init]))
    {
      NSMutableArray* tmpHtmlBareStrings=[NSMutableArray array];
      NSMutableData* tmpElementsMap=[[NSMutableData new]autorelease];
      ASSIGN(_elementName,anElementName);//??

      if (anElementName)
        {
          [tmpHtmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
                                                  anElementName]];
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
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)_initWithElementsMap:(NSData*)tmpElementsMap
          htmlBareStrings:(NSArray*)tmpHtmlBareStrings
          dynamicChildren:(NSArray*)aDynamicChildrensArray
{
  BOOL compactHTMLTags=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"tmpElementsMap=%@ tmpHtmlBareStrings:%@ dynamicChildren=%@",
		tmpElementsMap,
		tmpHtmlBareStrings,
		aDynamicChildrensArray);
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
              NSDebugMLLog(@"gswdync",@"rmString=[%@]",rmString);
              NSDebugMLLog(@"gswdync",@"[tmpHtmlBareStrings objectAtIndex:rmStringN]=[%@]",
                           [tmpHtmlBareStrings objectAtIndex:rmStringN]);
              [rmString appendString:[tmpHtmlBareStrings objectAtIndex:rmStringN]];
            };
          NSDebugMLLog(@"gswdync",@"rmString=[%@]",rmString);
          NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
          [rmStrings addObject:rmString];
          NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
          for(rmStringN=elementN;rmStringN<[tmpHtmlBareStrings count];rmStringN++)
            {
              NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
              NSDebugMLLog(@"gswdync",@"[tmpHtmlBareStrings objectAtIndex:rmStringN]=[%@]",
                           [tmpHtmlBareStrings objectAtIndex:rmStringN]);
              [rmStrings addObject:[tmpHtmlBareStrings objectAtIndex:rmStringN]];
            };
          NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
          tmpHtmlBareStrings=rmStrings;
        };
    };
  ASSIGN(_htmlBareStrings,tmpHtmlBareStrings);
  ASSIGN(_elementsMap,tmpElementsMap);
  ASSIGN(_dynamicChildren,aDynamicChildrensArray);

  LOGObjectFnStop();
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
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%@ %p elementsMap:%@>",
/* htmlBareStrings:%@ dynamicChildren:%@ elementName:%@>",*/
				   [self class],
				   (void*)self,
				   _elementsMap];
/*				   _htmlBareStrings,
				   _dynamicChildren,
				   _elementName];*/
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK (verifier avec GSWSession appendToR
  GSWRequest* request=[context request];
  BOOL isFromClientComponent=[request isFromClientComponent]; //bis repetitam
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ self=%p",
               [self class],[context elementID],self);
  GSWSaveAppendToResponseElementID(context);//Debug Only
  if ([_elementsMap length]>0)
    {
      [self appendToResponse:response
            inContext:context
            elementsFromIndex:0
            toIndex:[_elementsMap length]-1];
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@ self=%p",
               [self class],[context elementID],self);
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
	  elementsFromIndex:(unsigned int)fromIndex
                toIndex:(unsigned int)toIndex
{
  //OK
  NSStringEncoding encoding=[response contentEncoding];
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
          NSDebugMLLog(@"gswdync",@"%d:htmlBareString : %@",
                       elementN,[_htmlBareStrings objectAtIndex:elementsN[0]]);
          if (elementN>=fromIndex)
            [response appendContentData:[[_htmlBareStrings objectAtIndex:elementsN[0]]
                                          dataUsingEncoding:encoding]];
          elementsN[0]++;
        }
      else if (element==ElementsMap_dynamicElement)
        {
          if (elementN>=fromIndex)
            {
              NSDebugMLLog(@"gswdync",@"%d:dynamicElement : %@",
                           elementN,[aDynamicChildrensArray objectAtIndex:elementsN[1]]);                  
              NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",
                           [[aDynamicChildrensArray objectAtIndex:elementsN[1]] class],
                           [context elementID]);
              [[aDynamicChildrensArray objectAtIndex:elementsN[1]] appendToResponse:response
                                                                   inContext:context];
              [context incrementLastElementIDComponent];
            };
          elementsN[1]++;
        }
      else if (element==ElementsMap_attributeElement)
        {
          //TODO
          NSDebugMLLog(@"gswdync",@"%d:attributeElement",elementN);                  
          elementsN[2]++;
        };
    };
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  int elementN=0;
  NSArray* aDynamicChildrensArray=[self dynamicChildren];
  const BYTE* elements=[_elementsMap bytes];
  BYTE elementIndic=0;
  int elementsN[3]={0,0,0};
  BOOL searchIsOver=NO;
  NSString* senderID=nil;
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",
               [self class],[context elementID],[context senderID]);
  GSWAssertCorrectElementID(context);// Debug Only
  senderID=[context senderID];
  for(elementN=0;!element && !searchIsOver && elementN<[_elementsMap length];elementN++)
    {
      elementIndic=(BYTE)elements[elementN];
      if (elementIndic==ElementsMap_htmlBareString)
        elementsN[0]++;
      else if (elementIndic==ElementsMap_dynamicElement)
        {
          NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",
                       [[aDynamicChildrensArray objectAtIndex:elementsN[1]] class],
                       [context elementID]);
          element=[[aDynamicChildrensArray objectAtIndex:elementsN[1]] invokeActionForRequest:request
                                                                       inContext:context];
          //if (![context_ _wasFormSubmitted] && [[context_ elementID] compare:_senderID]==NSOrderedDescending)
          if (![context _wasFormSubmitted] && [[context elementID] isSearchOverForSenderID:senderID])
            {
              NSDebugMLLog(@"gswdync",@"id=%@ senderid=%@ => search is over",
                           [context elementID],
                           senderID);
              searchIsOver=YES;
            };
          [context incrementLastElementIDComponent];
          elementsN[1]++;
        }
      else if (elementIndic==ElementsMap_attributeElement)
        {
          elementsN[2]++;
        };
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  int elementN=0;
  NSArray* aDynamicChildrensArray=[self dynamicChildren];
  const BYTE* elements=[_elementsMap bytes];
  BYTE elementIndic=0;
  int elementsN[3]={0,0,0};
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",
               [self class],[context elementID]);
  GSWAssertCorrectElementID(context);// Debug Only
  for(elementN=0;elementN<[_elementsMap length];elementN++)
    {
      NSDebugMLLog(@"gswdync",@"elementN=%d",elementN);
      elementIndic=(BYTE)elements[elementN];
      NSDebugMLLog(@"gswdync",@"element=%x",(unsigned int)elementIndic);
      if (elementIndic==ElementsMap_htmlBareString)
        elementsN[0]++;
      else if (elementIndic==ElementsMap_dynamicElement)
        {
          NSDebugMLLog(@"gswdync",@"\n[aDynamicChildrensArray objectAtIndex:elementsN[1]=%@",
                       [aDynamicChildrensArray objectAtIndex:elementsN[1]]);
          NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",
                       [[aDynamicChildrensArray objectAtIndex:elementsN[1]] class],
                       [context elementID]);
          [[aDynamicChildrensArray objectAtIndex:elementsN[1]] takeValuesFromRequest:request
                                                               inContext:context];
          [context incrementLastElementIDComponent];
          elementsN[1]++;
        }
      else if (elementIndic==ElementsMap_attributeElement)
        {
          elementsN[2]++;
        };
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",
               [self class],[context elementID]);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementB)

//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)canBeFlattenedAtInitialization
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementC)

//--------------------------------------------------------------------
+(BOOL)charactersNeedingQuotes
{
  LOGClassFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(void)addURLAttribute:(id)attribute
       forElementNamed:(NSString*)name
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(id)urlsForElementNamed:(NSString*)name
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementD)

//--------------------------------------------------------------------
+(NSDictionary*)attributeDictionaryForString:(NSString*)string
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(NSString*)stringForAttributeDictionary:(NSDictionary*)attributeDictionary
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name
              attributeString:(NSString*)attributeString
              contentElements:(NSArray*)elements
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementE)

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name
          attributeDictionary:(NSDictionary*)attributeDictionary
              contentElements:(NSArray*)elements
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

+(Class)_elementClassForName:(NSString*)name
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

+(void)setElementClass:(Class)class
               forName:(NSString*)name
{
  LOGClassFnNotImplemented();	//TODOFN
};

+(GSWElement*)_theEmptyElement
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end 
