/** GSWHTMLDynamicElement.m - <title>GSWeb: Class GSWHTMLDynamicElement</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

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

//====================================================================
@implementation GSWHTMLDynamicElement


//--------------------------------------------------------------------
-(id)initWithName:(NSString*)elementName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{ 
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"gswdync",@"elementName=%@ associations:%@ elements=%@",elementName,associations,elements);
  if ((self=[super initWithName:elementName
                   associations:associations
                   template:nil]))
    {
    };
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)elementName
attributeAssociations:(NSDictionary*)attributeAssociations
  contentElements:(NSArray*)elements
{
  //OK
  NSString* dynamicElementName=[[self elementName] uppercaseString];
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"elementName=%@ attributeAssociations_:%@ elements=%@ dynamicElementName=%@",
		elementName,
		attributeAssociations,
		elements,
		dynamicElementName);
  if ((self=[super initWithName:dynamicElementName
                   associations:attributeAssociations
                   template:nil]))
    {
      NSMutableArray* attributeAssociationsValues=[NSMutableArray array];
      NSEnumerator* attributesKeyEnum=nil;
      id key=nil;
      NSMutableArray* htmlBareStrings=[NSMutableArray array];
      NSMutableData* elementsMap=[[NSMutableData new]autorelease];
      BOOL hasGSWebObjectsAssociations=NO;
      int GSWebObjectsAssociationsCount=0;
      BOOL escapeHTML=[[self class] escapeHTML];// (return NO)
      if (escapeHTML)
        {
          //TODO
        };

      //("<INPUT", " type", "=", text, ">")
      if (dynamicElementName)
        {
          [htmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
                                               dynamicElementName]];
          [elementsMap appendBytes:&ElementsMap_htmlBareString
                       length:1];
        };

      attributesKeyEnum= [attributeAssociations keyEnumerator];
      NSDebugMLLog(@"gswdync",@"attributesKeyEnum=%@ attributeAssociations=%@",
                   attributesKeyEnum,attributeAssociations);
      while ((key = [attributesKeyEnum nextObject]))
        {
          id association=[attributeAssociations objectForKey:key];
          id associationValue=[association valueInComponent:nil];
          NSDebugMLLog(@"gswdync",@"association=%@ associationValue=%@",
                       association,associationValue);
          [htmlBareStrings addObject:[NSString stringWithFormat:@" %@",key]];
          [elementsMap appendBytes:&ElementsMap_htmlBareString
                       length:1];
          if (associationValue)
            {
              [htmlBareStrings addObject:[NSString stringWithString:@"="]];
              [elementsMap appendBytes:&ElementsMap_htmlBareString
                           length:1];
              associationValue=[NSString stringWithFormat:@"%@",associationValue];
              // Parser remove "";
              if (![associationValue hasPrefix:@"\""])
                associationValue=[NSString stringWithFormat:@"\"%@\"",associationValue];
              NSDebugMLLog(@"gswdync",@"'associationValue'='%@'",
                           associationValue);
              [htmlBareStrings addObject:associationValue];
              [elementsMap appendBytes:&ElementsMap_htmlBareString
                           length:1];
            }
          else
            {
              //TODOV
              [attributeAssociationsValues addObject:association];
              [elementsMap appendBytes:&ElementsMap_attributeElement
                           length:1];
                  
            };
        };
      GSWebObjectsAssociationsCount=[self GSWebObjectsAssociationsCount];
      if (GSWebObjectsAssociationsCount>0)
        hasGSWebObjectsAssociations=YES;
      else
        hasGSWebObjectsAssociations=[[self class]hasGSWebObjectsAssociations]; //return:YES
      if (hasGSWebObjectsAssociations)
        {
          [elementsMap appendBytes:&ElementsMap_gswebElement
                       length:1];
        };
      [htmlBareStrings addObject:@">"];
      [elementsMap appendBytes:&ElementsMap_htmlBareString
                   length:1];
      if (elements)
        {
          int elementsN=[elements count];
          for(;elementsN>0;elementsN--)
            [elementsMap appendBytes:&ElementsMap_dynamicElement
                         length:1];
          if (dynamicElementName)
            {
              [htmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
                                                   dynamicElementName]];
              [elementsMap appendBytes:&ElementsMap_htmlBareString
                           length:1];
            };
        };
      [self _initWithElementsMap:elementsMap
            htmlBareStrings:htmlBareStrings
            dynamicChildren:elements
            attributeAssociations:attributeAssociationsValues];
    };
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)elementName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"elementName=[%@] associations=[%@] templateElement=[%@]",
               elementName,associations,templateElement);
  //OK
  if ((self=[self initWithName:elementName
                  associations:associations
                  contentElements:templateElement ? [NSArray arrayWithObject:templateElement] : nil]))
    {
    };
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_elementsMap);
  DESTROY(_htmlBareStrings);
  DESTROY(_dynamicChildren);
  DESTROY(_attributeAssociations);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)_initWithElementsMap:(NSData*)elementsMap
          htmlBareStrings:(NSArray*)htmlBareStrings
          dynamicChildren:(NSArray*)dynamicChildren
    attributeAssociations:(NSArray*)attributeAssociations
{
  BOOL compactHTMLTags=NO;
  BOOL hasGSWebObjectsAssociations=NO;
  int GSWebObjectsAssociationsCount=0;
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"elementsMap=%@ htmlBareStrings:%@ dynamicChildren=%@ attributeAssociations=%@",
               elementsMap,
               htmlBareStrings,
               dynamicChildren,
               attributeAssociations);
  compactHTMLTags=[self compactHTMLTags];
  //OK
  if (compactHTMLTags)
    {
      int elementN=0;
      while(elementN<[elementsMap length] && ((BYTE*)[elementsMap bytes])[elementN]==ElementsMap_htmlBareString)
        elementN++;
      NSDebugMLLog(@"gswdync",@"elementN=%d",elementN);
      [self _setEndOfHTMLTag:elementN];
      if (elementN>0)
        {
          int rmStringN=0;
          NSMutableArray* rmStrings=[NSMutableArray array];
          NSMutableString* rmString=[[NSMutableString new] autorelease];
          NSMutableData* tmpElementsMap=[[NSMutableData new] autorelease];
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
          [tmpElementsMap appendBytes:&ElementsMap_htmlBareString
                          length:1];
          if ([elementsMap length]>elementN)
            [tmpElementsMap appendData:[elementsMap subdataWithRange:
                                                      NSMakeRange(elementN,
                                                                  [elementsMap length]-elementN)]];
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
          elementsMap=tmpElementsMap;
          for(rmStringN=0;rmStringN<elementN;rmStringN++)
            {
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
              NSDebugMLLog(@"gswdync",@"rmString=%@ [_htmlBareStrings objectAtIndex:rmStringN]=%@",
                           rmString,
                           [htmlBareStrings objectAtIndex:rmStringN]);
              [rmString appendString:[htmlBareStrings objectAtIndex:rmStringN]];
            };
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
          [rmStrings addObject:rmString];
          NSDebugMLLog(@"gswdync",@"rmStrings=%@",rmStrings);
          for(rmStringN=elementN;rmStringN<[htmlBareStrings count];rmStringN++)
            {
              NSDebugMLLog(@"gswdync",@"rmStrings=%@ [htmlBareStrings objectAtIndex:rmStringN]=%@",
                           rmStrings,
                           [htmlBareStrings objectAtIndex:rmStringN]);
              [rmStrings addObject:[htmlBareStrings objectAtIndex:rmStringN]];
            };
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
          htmlBareStrings=rmStrings;
          NSDebugMLLog(@"gswdync",@"elementsMap=%@ htmlBareStrings:%@",
                       elementsMap,
                       htmlBareStrings);
        };
    };
  NSDebugMLLog(@"gswdync",@"XXXXXX");//XXXXXXX
  [self setHtmlBareStrings:htmlBareStrings]; 
  GSWebObjectsAssociationsCount=[self GSWebObjectsAssociationsCount];
  if (GSWebObjectsAssociationsCount>0)
    hasGSWebObjectsAssociations=YES;
  else
    hasGSWebObjectsAssociations=[[self class]hasGSWebObjectsAssociations];
  if (hasGSWebObjectsAssociations)
    {
      //TODO
    };
  
  ASSIGN(_elementsMap,elementsMap);
							  
  ASSIGN(_dynamicChildren,dynamicChildren);
  ASSIGN(_attributeAssociations,attributeAssociations);

  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  //OK
  [self subclassResponsibility:_cmd];
  return nil;
};

//--------------------------------------------------------------------
-(NSArray*)dynamicChildren
{
  //OK
  return _dynamicChildren;
};

//--------------------------------------------------------------------
-(NSArray*)htmlBareStrings
{
  //OK
  return _htmlBareStrings;
};

//--------------------------------------------------------------------
-(NSData*)elementsMap
{
  //OK
  return _elementsMap;
};

//--------------------------------------------------------------------
-(NSArray*)attributeAssociations
{
  //OK
  return _attributeAssociations;
};

//--------------------------------------------------------------------
-(void)_setEndOfHTMLTag:(unsigned int)unknown
{
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%@ %p elementsMap:%@ htmlBareStrings:%@ dynamicChildren:%@ attributeAssociations:%@>",
                   [self class],
                   (void*)self,
                   _elementsMap,
                   _htmlBareStrings,
                   _dynamicChildren,
                   _attributeAssociations];
};

//--------------------------------------------------------------------
-(void)setHtmlBareStrings:(NSArray*)htmlBareStrings
{
  ASSIGN(_htmlBareStrings,htmlBareStrings);
};


@end

//====================================================================
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementA)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(unsigned int)GSWebObjectsAssociationsCount
{
  return 1;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);//Debug Only
  if ([_elementsMap length]>0)
    {
      [self appendToResponse:aResponse
            inContext:aContext
            elementsFromIndex:0
            toIndex:[_elementsMap length]-1];
    };
  GSWStopElement(aContext);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
      elementsFromIndex:(unsigned int)fromIndex
                toIndex:(unsigned int)toIndex
{
  //OK
  NSStringEncoding encoding=0;
  NSArray* dynamicChildren=nil;
  GSWComponent* component=nil;
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  NSArray* attributeAssociations=nil;
  int elementN=0;
  const BYTE* elements=[_elementsMap bytes];
  BYTE element=0;
  int elementsN[4]={0,0,0,0};
  BOOL inChildren=NO;
#ifndef NDEBUG
  NSString* debugElementID=nil;
#endif
  LOGObjectFnStartC("GSWHTMLDynamicElement");

  encoding=[aResponse contentEncoding];
  dynamicChildren=[self dynamicChildren];//call dynamicChildren //GSWTextField: nil
  NSDebugMLLog(@"gswdync",@"dynamicChildren=%@",dynamicChildren);
  component=[aContext component];
  request=[aContext request];
  isFromClientComponent=[request isFromClientComponent]; //return NO
  attributeAssociations=[self attributeAssociations]; //return nil for GSWTextField/GSWSubmitButton;

  NSAssert2(fromIndex<[_elementsMap length],@"fromIndex out of range:%u (length=%d)",
            fromIndex,[_elementsMap length]);
  NSAssert2(toIndex<[_elementsMap length],@"toIndex out of range:%u (length=%d)",
            toIndex,[_elementsMap length]);
  NSAssert2(fromIndex<=toIndex,@"fromIndex>toIndex %u %u ",
            fromIndex,toIndex);
  NSDebugMLLog(@"gswdync",@"Starting HTMLDyn AR ET=%@ id=%@",
               [self class],[aContext elementID]);
  for(elementN=0;elementN<=toIndex;elementN++)
    {
      element=(BYTE)elements[elementN];
      NSDebugMLLog(@"gswdync",@"elements=%c",element);
      if (element==ElementsMap_dynamicElement)
        {
          if (!inChildren)
            {
#ifndef NDEBUG
              debugElementID=[aContext elementID];
#endif
              [aContext appendZeroElementIDComponent];
              inChildren=YES;
            };
        }
      else
        {
          if (inChildren)
            {
              [aContext deleteLastElementIDComponent];
              inChildren=NO;
#ifndef NDEBUG
              if (![debugElementID isEqualToString:[aContext elementID]])
                {
                  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [aContext elementID]=%@",
                               [self class],debugElementID,[aContext elementID]);
                  
                };
#endif
            };
        };
      if (element==ElementsMap_htmlBareString)
        {
          if (elementN>=fromIndex)
            [aResponse appendContentString:[_htmlBareStrings objectAtIndex:elementsN[0]]];
          elementsN[0]++;
        }
      else if (element==ElementsMap_gswebElement)
        {
          if (elementN>=fromIndex)
            [self appendGSWebObjectsAssociationsToResponse:aResponse
                  inContext:aContext];
          elementsN[1]++;
        }
      else if (element==ElementsMap_dynamicElement)
        {
          if (elementN>=fromIndex)
            {
              NSDebugMLLog(@"gswdync",@"appendToResponse i=%d",
                           elementN);
              [[dynamicChildren objectAtIndex:elementsN[2]] appendToResponse:aResponse
                                                            inContext:aContext];
              [aContext incrementLastElementIDComponent];
            };
          elementsN[2]++;
        }
      else if (element==ElementsMap_attributeElement)
        {
          if (elementN>=fromIndex)
            {
              GSWAssociation* association=[_attributeAssociations objectAtIndex:elementsN[3]];
              id value=[association valueInComponent:component];
              if (value)
                {
                  [aResponse appendContentString:@"=\""];
                  [aResponse appendContentHTMLAttributeValue:value];
                  [aResponse appendContentString:@"\""];
                };
            };
          elementsN[3]++;
        };
    };
  if (inChildren)
    {
      [aContext deleteLastElementIDComponent];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[aContext elementID]])
        {
          NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [aContext elementID]=%@",
                       [self class],debugElementID,[aContext elementID]);          
        };
#endif
    };
  GSWStopElement(aContext);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};


//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  //???
  GSWElement* element=nil;
  NSString* senderID=nil;
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);// Debug Only
  senderID=[aContext senderID];
  if ([_elementsMap length]>0)
    {
      int elementN=0;
      NSArray* dynamicChildren=[self dynamicChildren];
      const BYTE* elements=[_elementsMap bytes];
      BYTE elementIndic=0;
      int elementsN[4]={0,0,0,0};
      BOOL searchIsOver=NO;
      BOOL inChildren=NO;
#ifndef NDEBUG
      NSString* debugElementID=nil;
#endif
      for(elementN=0;!element && !searchIsOver && elementN<[_elementsMap length];elementN++)
        {
          elementIndic=(BYTE)elements[elementN];      
          if (elementIndic==ElementsMap_dynamicElement)
            {
              if (!inChildren)
                {
#ifndef NDEBUG
                  debugElementID=[aContext elementID];
#endif
                  [aContext appendZeroElementIDComponent];
                  inChildren=YES;
                };
            }
          else
            {
              if (inChildren)
                {
                  [aContext deleteLastElementIDComponent];
                  inChildren=NO;
#ifndef NDEBUG
                  if (![debugElementID isEqualToString:[aContext elementID]])
                    {
                      NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [aContext elementID]=%@",
                                   [self class],
                                   debugElementID,
                                   [aContext elementID]);
                      
                    };
#endif
                };
            };
          if (elementIndic==ElementsMap_htmlBareString)
            elementsN[0]++;
          else if (elementIndic==ElementsMap_gswebElement)
            elementsN[1]++;
          else if (elementIndic==ElementsMap_dynamicElement)
            {
              element=[[dynamicChildren objectAtIndex:elementsN[2]] invokeActionForRequest:aRequest
                                                                    inContext:aContext];
              NSAssert3(!element || [element isKindOfClass:[GSWElement class]],
                        @"From: %@ Element is a %@ not a GSWElement: %@",
                        [dynamicChildren objectAtIndex:elementsN[2]],
                        [element class],
                        element);
              if (![aContext _wasFormSubmitted] && [[aContext elementID] isSearchOverForSenderID:senderID])
                {
                  NSDebugMLLog(@"gswdync",@"id=%@ senderid=%@ => search is over",
                               [aContext elementID],
                               senderID);
                  searchIsOver=YES;
                };
              [aContext incrementLastElementIDComponent];
              elementsN[2]++;
            }
          else if (elementIndic==ElementsMap_attributeElement)
            elementsN[3]++;
        };
  if (inChildren)
    {
      [aContext deleteLastElementIDComponent];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[aContext elementID]])
        {
          NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [aContext elementID]=%@",
                       [self class],debugElementID,[aContext elementID]);
          
        };
#endif
    };
    };
  GSWStopElement(aContext);
  NSDebugMLLog(@"gswdync",@"senderID=%@",[aContext senderID]);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return element;
};


//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  if ([_elementsMap length]>0)
    {
      int elementN=0;
      NSArray* dynamicChildren=[self dynamicChildren];
      const BYTE* elements=[_elementsMap bytes];
      BYTE element=0;
      int elementsN[4]={0,0,0,0};
      BOOL inChildren=NO;
#ifndef NDEBUG
      NSString* debugElementID=nil;
#endif
      for(elementN=0;elementN<[_elementsMap length];elementN++)
	{
	  element=(BYTE)elements[elementN];
	  if (element==ElementsMap_dynamicElement)
            {
              if (!inChildren)
                {
#ifndef NDEBUG
                  debugElementID=[aContext elementID];
#endif
                  [aContext appendZeroElementIDComponent];
                  inChildren=YES;
                };
            }
	  else
            {
              if (inChildren)
                {
                  [aContext deleteLastElementIDComponent];
                  inChildren=NO;
#ifndef NDEBUG
                  if (![debugElementID isEqualToString:[aContext elementID]])
                    {
                      NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [aContext elementID]=%@",
                                   [self class],debugElementID,[aContext elementID]);                      
                    };
#endif
                };
            };

	  if (element==ElementsMap_htmlBareString)
            elementsN[0]++;
	  else if (element==ElementsMap_gswebElement)
            elementsN[1]++;
	  else if (element==ElementsMap_dynamicElement)
            {
              NSDebugMLLog(@"gswdync",@"i=%d",
                           elementN);
              [[dynamicChildren objectAtIndex:elementsN[2]] takeValuesFromRequest:aRequest
                                                            inContext:aContext];
              [aContext incrementLastElementIDComponent];
              elementsN[2]++;
            }
	  else if (element==ElementsMap_attributeElement)
		elementsN[3]++;
	};
      if (inChildren)
	{
	  [aContext deleteLastElementIDComponent];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[aContext elementID]])
            {
              NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [aContext elementID]=%@",
                           [self class],debugElementID,[aContext elementID]);              
            };
#endif
	};
    };
  GSWStopElement(aContext);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};
 
@end

//====================================================================
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementB)

//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  return YES;
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
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementC)

//--------------------------------------------------------------------
+(void)setDynamicElementCompaction:(BOOL)flag
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(BOOL)escapeHTML
{
  //OK?
  return NO;
};

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  //OK ?
  return NO;
};

@end


//====================================================================
//@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementD)
// move it to GSWHTMLDynamicElement later !!!!

@implementation GSWDynamicElement (GSWHTMLDynamicElementD)

//--------------------------------------------------------------------
-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                              directActionNameAssociation:(GSWAssociation*)directActionName
                                                inContext:(GSWContext*)context
{
  return [self computeActionStringWithActionClassAssociation:actionClass
               directActionNameAssociation:directActionName
               otherPathQueryAssociations:nil
               inContext:context];
};

//--------------------------------------------------------------------
-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                              directActionNameAssociation:(GSWAssociation*)directActionName
                               otherPathQueryAssociations:(NSDictionary*)otherPathQueryAssociations
                                                inContext:(GSWContext*)context
{
  return [self computeActionStringWithActionClassAssociation:actionClass
               directActionNameAssociation:directActionName
               pathQueryDictionaryAssociation:nil
               otherPathQueryAssociations:nil
               inContext:context];
};

//--------------------------------------------------------------------
-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                              directActionNameAssociation:(GSWAssociation*)directActionName
                           pathQueryDictionaryAssociation:(GSWAssociation*)pathQueryDictionaryAssociation
                               otherPathQueryAssociations:(NSDictionary*)otherPathQueryAssociations
                                                inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  id tmpDirectActionString=nil;
  id directActionNameValue=nil;
  id actionClassValue=nil;
  LOGObjectFnStart();
  component=[context component];
  if (directActionName)
    directActionNameValue=[directActionName valueInComponent:component];
  if (actionClass)
    actionClassValue=[actionClass valueInComponent:component];

  if (actionClassValue)
    {
      if (directActionNameValue)
        tmpDirectActionString=[NSString stringWithFormat:@"%@/%@",
                                        actionClassValue,
                                        directActionNameValue];
      else
        tmpDirectActionString=actionClassValue;
    }
  else if (directActionNameValue)
    tmpDirectActionString=directActionNameValue;
  else
    {
      LOGSeriousError(@"No actionClass (for %@) and no directActionName (for %@)",
                      actionClass,
                      directActionName);
    };

  if (tmpDirectActionString)
    {
      NSDictionary* pathQueryDictionary=nil;
      if (pathQueryDictionaryAssociation)
        {
          NSDebugMLLog(@"gswdync",@"pathQueryDictionaryAssociation=%@",
                       pathQueryDictionaryAssociation);

          pathQueryDictionary=[pathQueryDictionaryAssociation 
                                valueInComponent:component];

          NSDebugMLLog(@"gswdync",@"pathQueryDictionary=%@",
                       pathQueryDictionary);
        };
      if ([pathQueryDictionary count]>0 || [otherPathQueryAssociations count]>0)
        {
          NSMutableDictionary* pathKV=nil;
	  NSArray* keys;
	  unsigned int count;
	  unsigned int i;

          if ([otherPathQueryAssociations count]>0)
            {              
              NSEnumerator* enumerator = [otherPathQueryAssociations keyEnumerator];
              id key=nil;
              pathKV=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              while ((key = [enumerator nextObject]))
                {
                  id association = [otherPathQueryAssociations valueForKey:key];
                  id associationValue=[association valueInComponent:component];
                  NSDebugMLLog(@"gswdync",@"key=%@",key);
                  NSDebugMLLog(@"gswdync",@"association=%@",association);
                  NSDebugMLLog(@"gswdync",@"associationValue=%@",associationValue);
                  if (!associationValue)
                    associationValue=[NSString string];
                  [pathKV setObject:associationValue
                          forKey:key];
                };
              if ([pathQueryDictionary count]>0)
                [pathKV addEntriesFromDictionary:pathQueryDictionary];
            }
          else
            pathKV=(NSMutableDictionary*)pathQueryDictionary;

          NSDebugMLLog(@"gswdync",@"pathKV=%@",pathKV);

          // We sort keys so URL are always the same for same parameters
          keys=[[pathKV allKeys]sortedArrayUsingSelector:@selector(compare:)];
          count=[keys count];

          NSDebugMLLog(@"gswdync",@"pathKV=%@",pathKV);
          for(i=0;i<count;i++)
            {
              id key = [keys objectAtIndex:i];
              id value = [pathKV valueForKey:key];
              NSDebugMLLog(@"gswdync",@"key=%@",key);
              NSDebugMLLog(@"gswdync",@"value=%@",value);
              tmpDirectActionString=[tmpDirectActionString stringByAppendingFormat:@"/%@=%@",
                                                           key,
                                                           value];
            };
        };
    };

  NSDebugMLLog(@"gswdync",@"tmpDirectActionString=%@",tmpDirectActionString);
  LOGObjectFnStop();
  return tmpDirectActionString;
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryWithActionClassAssociation:(GSWAssociation*)actionClass
                                     directActionNameAssociation:(GSWAssociation*)directActionName
                                      queryDictionaryAssociation:(GSWAssociation*)queryDictionary
                                          otherQueryAssociations:(NSDictionary*)otherQueryAssociations
                                                       inContext:(GSWContext*)context
{
  //OK
  NSMutableDictionary* finalQueryDictionary=nil;
  GSWComponent* component=nil;
  GSWSession* session=nil;
  NSString* sessionID=nil;
  LOGObjectFnStart();

  NSDebugMLLog(@"gswdync",@"actionClass=%@",actionClass);
  NSDebugMLLog(@"gswdync",@"directActionName=%@",directActionName);
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);
  NSDebugMLLog(@"gswdync",@"otherQueryAssociations=%@",otherQueryAssociations);

  component=[context component];
  session=[context existingSession];
  NSDebugMLog(@"session=%@",session);
  
  if (queryDictionary)
    {
      NSDictionary* queryDictionaryValue=[queryDictionary valueInComponent:component];
      if (queryDictionaryValue)
        {
          if ([queryDictionaryValue isKindOfClass:[NSMutableDictionary class]])
            finalQueryDictionary=(NSMutableDictionary*)queryDictionaryValue;
          else
            {
              NSAssert3([queryDictionaryValue isKindOfClass:[NSDictionary class]],
                        @"queryDictionary value is not a dictionary but a %@. association was: %@. queryDictionaryValue is:",
                        [queryDictionaryValue class],
                        queryDictionary,
                        queryDictionaryValue);
              finalQueryDictionary=[[queryDictionaryValue mutableCopy] autorelease];
            };
        };
    };
  if (!finalQueryDictionary)
    finalQueryDictionary=(NSMutableDictionary*)[NSMutableDictionary dictionary];

  if (session)
    sessionID=[session sessionID];
  NSDebugMLog(@"sessionID=%@",sessionID);
/*
in GSWHyperlink, it was
       if (!_action && !_pageName
          && (WOStrictFlag || (!WOStrictFlag && !_redirectURL))) //??
*/
  if(sessionID
     && (directActionName || actionClass) 
     && (!session || ![session storesIDsInCookies] || [session storesIDsInURLs]))
    [finalQueryDictionary setObject:sessionID
                          forKey:GSWKey_SessionID[GSWebNamingConv]];

  if (otherQueryAssociations)
    {
      NSEnumerator *enumerator = [otherQueryAssociations keyEnumerator];
      id associationKey=nil;
      while ((associationKey = [enumerator nextObject]))
        {
          id association = [otherQueryAssociations valueForKey:associationKey];
          id associationValue=[association valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"associationKey=%@",associationKey);
          NSDebugMLLog(@"gswdync",@"association=%@",association);
          NSDebugMLLog(@"gswdync",@"associationValue=%@",associationValue);
          if (!associationValue)
            associationValue=[NSString string];
          [finalQueryDictionary setObject:associationValue
                                forKey:associationKey];
        };
    };

  LOGObjectFnStop();
  return finalQueryDictionary;
};
@end

//====================================================================
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementCID)


-(NSString*)addCIDElement:(NSDictionary*)cidElement
                   forKey:(NSString*)cidKeyValue
   forCIDStoreAssociation:(GSWAssociation*)cidStore
                inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"cidElement=%@",cidElement);
  NSDebugMLog(@"cidKeyValue=%@",cidKeyValue);
  NSDebugMLog(@"cidStore=%@",cidStore);
  if (cidElement && cidStore)
    {
      id cidObject=nil;
      GSWComponent* component=[aContext component];
      cidObject=[cidStore valueInComponent:component];
      NSDebugMLog(@"cidObject=%@",cidObject);
/*      if (!cidObject)
        {
          cidObject=(NSMutableDictionary*)[NSMutableDictionary dictionary];
          [_cidStore setValue:cidObject
                   inComponent:component];
        };
*/
      if (cidObject)
        {
          if (![cidObject valueForKey:cidKeyValue])
            [cidObject takeValue:cidElement
                       forKey:cidKeyValue];
          newURL=[NSString stringWithFormat:@"cid:%@",
                           cidKeyValue];
        };
      NSDebugMLog(@"newURL=%@",newURL);
    };
  LOGObjectFnStop();
  return newURL;
};

//--------------------------------------------------------------------
-(NSString*)addURL:(NSString*)url
forCIDKeyAssociation:(GSWAssociation*)cidKey
CIDStoreAssociation:(GSWAssociation*)cidStore
         inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (url && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[cidKey valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"cidKeyValue=%@",cidKeyValue);
      if (!cidKeyValue)
        {
          // We calculate cidKeyValue by computing md5 on url
          // so there will be no duplicate elements with different keys
	  NSData* data = [url dataUsingEncoding: NSISOLatin1StringEncoding];
	  cidKeyValue=[[data md5Digest] hexadecimalRepresentation];
        };
      newURL=[self addCIDElement:[NSDictionary dictionaryWithObject:url
                                               forKey:@"url"]
                   forKey:cidKeyValue
                   forCIDStoreAssociation:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};


//--------------------------------------------------------------------
-(NSString*)addURLValuedElementData:(GSWURLValuedElementData*)data
               forCIDKeyAssociation:(GSWAssociation*)cidKey
                CIDStoreAssociation:(GSWAssociation*)cidStore
                          inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (data && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[cidKey valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"cidKeyValue=%@",cidKeyValue);
      if (!cidKeyValue)
        {
          // We calculate cidKeyValue by computing md5 on path
          // so there will be no duplicate elements with different keys
          //NSString* cidKeyValue=[[data md5Digest] hexadecimalRepresentation];
          cidKeyValue=[data key];
        };
      newURL=[self addCIDElement:[NSDictionary dictionaryWithObject:data
                                               forKey:@"data"]
                   forKey:cidKeyValue
                   forCIDStoreAssociation:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};


//--------------------------------------------------------------------
-(NSString*)addPath:(NSString*)path
forCIDKeyAssociation:(GSWAssociation*)cidKey
CIDStoreAssociation:(GSWAssociation*)cidStore
          inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (path && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[cidKey valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"cidKeyValue=%@",cidKeyValue);
      if (!cidKeyValue)
        {
          // We calculate cidKeyValue by computing md5 on path
          // so there will be no duplicate elements with different keys
	  NSData* data = [path dataUsingEncoding: NSISOLatin1StringEncoding];
	  cidKeyValue=[[data md5Digest] hexadecimalRepresentation];
        };

      newURL=[self addCIDElement:[NSDictionary dictionaryWithObject:path
                                               forKey:@"filePath"]
                   forKey:cidKeyValue
                   forCIDStoreAssociation:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};

@end
