/* GSWHTMLStaticElement.m - GSWeb: Class GSWHTMLStaticElement
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWHTMLStaticElement

//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)_elementName
	 attributeDictionary:(NSDictionary*)attributeAssociations_
		 contentElements:(NSArray*)_elements
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_elementName=%@ attributeAssociations_:%@ _elements=%@",
		_elementName,
		attributeAssociations_,
		_elements);
  if ((self=[super init]))
	{
	  NSMutableArray* _attributeAssociationsValues=[NSMutableArray array];
	  NSMutableArray* _htmlBareStrings=[NSMutableArray array];
	  NSMutableData* _elementsMap=[[NSMutableData new]autorelease];
	  ASSIGN(elementName,_elementName);//??

	  if (_elementName)
		{
		  NSEnumerator* attributesKeyEnum=nil;
		  id _key=nil;
		  [_htmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
												 _elementName]];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						 length:1];

		  attributesKeyEnum= [attributeAssociations_ keyEnumerator];
		  NSDebugMLLog(@"gswdync",@"attributesKeyEnum=%@ attributeAssociations_=%@",attributesKeyEnum,attributeAssociations_);
		  while ((_key = [attributesKeyEnum nextObject]))
			{
			  id _association=[attributeAssociations_ objectForKey:_key];
			  id _associationValue=[_association valueInComponent:nil];
			  NSDebugMLLog(@"gswdync",@"_association=%@ _associationValue=%@",_association,_associationValue);
			  [_htmlBareStrings addObject:[NSString stringWithFormat:@" %@",_key]];
			  [_elementsMap appendBytes:&ElementsMap_htmlBareString
							 length:1];
			  if (_associationValue)
				{
				  [_htmlBareStrings addObject:[NSString stringWithString:@"="]];
				  [_elementsMap appendBytes:&ElementsMap_htmlBareString
								 length:1];
				  [_htmlBareStrings addObject:[NSString stringWithFormat:@"%@",_associationValue]];
				  [_elementsMap appendBytes:&ElementsMap_htmlBareString
								 length:1];
				}
			  else
				{
				  //TODO So what next ?
				  [_attributeAssociationsValues addObject:_association];
				  [_elementsMap appendBytes:&ElementsMap_attributeElement
								length:1];
				  
				};
			};
		  [_htmlBareStrings addObject:@">"];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						 length:1];
		};
	  if (_elements)
		{
		  int elementsN=[_elements count];
		  for(;elementsN>0;elementsN--)
			[_elementsMap appendBytes:&ElementsMap_dynamicElement
						   length:1];
		  if (_elementName)
			{
			  [_htmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
													 _elementName]];
			  [_elementsMap appendBytes:&ElementsMap_htmlBareString
							 length:1];
			};
		};
	  [self _initWithElementsMap:_elementsMap
			htmlBareStrings:_htmlBareStrings
			dynamicChildren:_elements];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)_elementName
		 attributeString:(NSString*)_attributeString
		 contentElements:(NSArray*)_elements
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_elementName=%@ _attributeString:%@ _elements=%@",
		_elementName,
		_attributeString,
		_elements);
  if ((self=[super init]))
	{
	  NSMutableArray* _htmlBareStrings=[NSMutableArray array];
	  NSMutableData* _elementsMap=[[NSMutableData new]autorelease];
	  ASSIGN(elementName,_elementName);//??

	  if (_elementName)
		{
		  [_htmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
												 _elementName]];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						 length:1];
		  [_htmlBareStrings addObject:_attributeString];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						 length:1];
		  [_htmlBareStrings addObject:@">"];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						 length:1];
		};
	  if (_elements)
		{
		  int elementsN=[_elements count];
		  for(;elementsN>0;elementsN--)
			[_elementsMap appendBytes:&ElementsMap_dynamicElement
						   length:1];
		  if (_elementName)
			{
			  [_htmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
													 _elementName]];
			  [_elementsMap appendBytes:&ElementsMap_htmlBareString
							 length:1];
			};
		};
	  [self _initWithElementsMap:_elementsMap
			htmlBareStrings:_htmlBareStrings
			dynamicChildren:_elements];	  
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)_initWithElementsMap:(NSData*)_elementsMap
		  htmlBareStrings:(NSArray*)_htmlBareStrings
		   dynamicChildren:(NSArray*)_dynamicChildren
{
  BOOL _compactHTMLTags=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_elementsMap=%@ _htmlBareStrings:%@ dynamicChildren=%@",
		_elementsMap,
		_htmlBareStrings,
		_dynamicChildren);
  _compactHTMLTags=[self compactHTMLTags];
  //OK
  if (_compactHTMLTags)
	{
	  int elementN=0;
	  while(elementN<[_elementsMap length] && ((BYTE*)[_elementsMap bytes])[elementN]==ElementsMap_htmlBareString)
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
		  if ([_elementsMap length]>elementN)
			[tmpElementsMap appendData:
							   [_elementsMap subdataWithRange:
												NSMakeRange(elementN,
															[_elementsMap length]-elementN)]];
		  _elementsMap=tmpElementsMap;
		  for(rmStringN=0;rmStringN<elementN;rmStringN++)
			{
			  NSDebugMLLog(@"gswdync",@"rmString=[%@]",rmString);
			  NSDebugMLLog(@"gswdync",@"[_htmlBareStrings objectAtIndex:rmStringN]=[%@]",
					 [_htmlBareStrings objectAtIndex:rmStringN]);
			  [rmString appendString:[_htmlBareStrings objectAtIndex:rmStringN]];
			};
		  NSDebugMLLog(@"gswdync",@"rmString=[%@]",rmString);
		  NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
		  [rmStrings addObject:rmString];
		  NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
		  for(rmStringN=elementN;rmStringN<[_htmlBareStrings count];rmStringN++)
			{
			  NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
			  NSDebugMLLog(@"gswdync",@"[_htmlBareStrings objectAtIndex:rmStringN]=[%@]",
					 [_htmlBareStrings objectAtIndex:rmStringN]);
			  [rmStrings addObject:[_htmlBareStrings objectAtIndex:rmStringN]];
			};
		  NSDebugMLLog(@"gswdync",@"rmStrings=[%@]",rmStrings);
		  _htmlBareStrings=rmStrings;
		};
	};
  ASSIGN(htmlBareStrings,_htmlBareStrings);
  ASSIGN(elementsMap,_elementsMap);
  ASSIGN(dynamicChildren,_dynamicChildren);

  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return elementName;
};

//--------------------------------------------------------------------
-(NSArray*)dynamicChildren
{
  return dynamicChildren;
};

//--------------------------------------------------------------------
-(NSArray*)htmlBareStrings
{
  return htmlBareStrings;
};

//--------------------------------------------------------------------
-(NSData*)elementsMap
{
  return elementsMap;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(elementsMap);
  DESTROY(htmlBareStrings);
  DESTROY(dynamicChildren);
  DESTROY(elementName);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)_setEndOfHTMLTag:(unsigned int)_unknown
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
				   elementsMap];
/*				   htmlBareStrings,
				   dynamicChildren,
				   elementName];*/
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK (verifier avec GSWSession appendToR
  GSWRequest* _request=[context_ request];
  BOOL _isFromClientComponent=[_request isFromClientComponent]; //bis repetitam
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  if ([elementsMap length]>0)
	{
	  [self appendToResponse:response_
			inContext:context_
			elementsFromIndex:0
			toIndex:[elementsMap length]-1];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
	  elementsFromIndex:(unsigned int)_fromIndex
				toIndex:(unsigned int)_toIndex
{
  //OK
  NSStringEncoding _encoding=[response_ contentEncoding];
  NSArray* _dynamicChildren=[self dynamicChildren];//call dynamicChildren //GSWTextField: nil
  int elementN=0;
  const BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[3]={0,0,0};
  NSAssert2(_fromIndex<[elementsMap length],@"_fromIndex out of range:%u (length=%d)",_fromIndex,[elementsMap length]);
  NSAssert2(_toIndex<[elementsMap length],@"_toIndex out of range:%u (length=%d)",_toIndex,[elementsMap length]);
  NSAssert2(_fromIndex<=_toIndex,@"_fromIndex>_toIndex %u %u ",_fromIndex,_toIndex);
  for(elementN=0;elementN<=_toIndex;elementN++)
	{
	  element=(BYTE)elements[elementN];
	  if (element==ElementsMap_htmlBareString)
		{
		  if (elementN>=_fromIndex)
			[response_ appendContentData:[[htmlBareStrings objectAtIndex:elementsN[0]] dataUsingEncoding:_encoding]];
		  elementsN[0]++;
		}
	  else if (element==ElementsMap_dynamicElement)
		{
		  if (elementN>=_fromIndex)
			{
			  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[_dynamicChildren objectAtIndex:elementsN[1]] class],[context_ elementID]);
			  [[_dynamicChildren objectAtIndex:elementsN[1]] appendToResponse:response_
															 inContext:context_];
			  [context_ incrementLastElementIDComponent];
			};
		  elementsN[1]++;
		}
	  else if (element==ElementsMap_attributeElement)
		{
		  //TODO
		  elementsN[2]++;
		};
	};
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  int elementN=0;
  NSArray* _dynamicChildren=[self dynamicChildren];
  const BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[3]={0,0,0};
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],[context_ elementID],[context_ senderID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  for(elementN=0;!_element && elementN<[elementsMap length];elementN++)
	{
	  element=(BYTE)elements[elementN];
	  if (element==ElementsMap_htmlBareString)
		  elementsN[0]++;
	  else if (element==ElementsMap_dynamicElement)
		{
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[_dynamicChildren objectAtIndex:elementsN[1]] class],[context_ elementID]);
		  _element=[[_dynamicChildren objectAtIndex:elementsN[1]] invokeActionForRequest:request_
																  inContext:context_];
		  [context_ incrementLastElementIDComponent];
		  elementsN[1]++;
		}
	  else if (element==ElementsMap_attributeElement)
		{
		  elementsN[2]++;
		};
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  return _element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  int elementN=0;
  NSArray* _dynamicChildren=[self dynamicChildren];
  const BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[3]={0,0,0};
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  for(elementN=0;elementN<[elementsMap length];elementN++)
	{
	  NSDebugMLLog(@"gswdync",@"elementN=%d",elementN);
	  element=(BYTE)elements[elementN];
	  NSDebugMLLog(@"gswdync",@"element=%x",(unsigned int)element);
	  if (element==ElementsMap_htmlBareString)
		  elementsN[0]++;
	  else if (element==ElementsMap_dynamicElement)
		{
		  NSDebugMLLog(@"gswdync",@"\n[_dynamicChildren objectAtIndex:elementsN[1]=%@",[_dynamicChildren objectAtIndex:elementsN[1]]);
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[_dynamicChildren objectAtIndex:elementsN[1]] class],[context_ elementID]);
		  [[_dynamicChildren objectAtIndex:elementsN[1]] takeValuesFromRequest:request_
														 inContext:context_];
		  [context_ incrementLastElementIDComponent];
		  elementsN[1]++;
		}
	  else if (element==ElementsMap_attributeElement)
		{
		  elementsN[2]++;
		};
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
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
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping
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
+(void)addURLAttribute:(id)_attribute
	   forElementNamed:(NSString*)_name
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(id)urlsForElementNamed:(NSString*)_name
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementD)

//--------------------------------------------------------------------
+(NSDictionary*)attributeDictionaryForString:(NSString*)string_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(NSString*)stringForAttributeDictionary:(NSDictionary*)attributeDictionary_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name_
			 attributeString:(NSString*)attributeString_
			 contentElements:(NSArray*)elements_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWHTMLStaticElement (GSWHTMLStaticElementE)

//--------------------------------------------------------------------
+(GSWElement*)elementWithName:(NSString*)name_
		 attributeDictionary:(NSDictionary*)attributeDictionary_
			 contentElements:(NSArray*)elements_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

+(Class)_elementClassForName:(NSString*)name_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

+(void)setElementClass:(Class)class_
			   forName:(NSString*)name_
{
  LOGClassFnNotImplemented();	//TODOFN
};

+(GSWElement*)_theEmptyElement
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end 
