/* GSWHTMLDynamicElement.m - GSWeb: Class GSWHTMLDynamicElement
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWHTMLDynamicElement


//--------------------------------------------------------------------
-(id)initWithName:(NSString*)_elementName
	 associations:(NSDictionary*)_associations
  contentElements:(NSArray*)_elements
{ 
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"gswdync",@"_elementName=%@ associations:%@ _elements=%@",_elementName,_associations,_elements);
  if ((self=[super initWithName:_elementName
				   associations:_associations
				   template:nil]))
	{
	};
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};


//--------------------------------------------------------------------
-(id)		initWithName:(NSString*)_elementName
   attributeAssociations:(NSDictionary*)attributeAssociations_
		 contentElements:(NSArray*)_elements
{
  //OK
  NSString* _dynamicElementName=[[self elementName] uppercaseString];
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"_elementName=%@ attributeAssociations_:%@ _elements=%@ _dynamicElementName=%@",
		_elementName,
		attributeAssociations_,
		_elements,
		_dynamicElementName);
  if ((self=[super initWithName:_dynamicElementName
				   associations:attributeAssociations_
				   template:nil]))
	{
	  NSMutableArray* _attributeAssociationsValues=[NSMutableArray array];
	  NSEnumerator* attributesKeyEnum=nil;
	  id _key=nil;
	  NSMutableArray* _htmlBareStrings=[NSMutableArray array];
	  NSMutableData* _elementsMap=[[NSMutableData new]autorelease];
	  BOOL _hasGSWebObjectsAssociations=NO;
	  int _GSWebObjectsAssociationsCount=0;
	  BOOL _escapeHTML=[[self class] escapeHTML];// (return NO)
	  if (_escapeHTML)
		{
		  //TODO
		};

	  //("<INPUT", " type", "=", text, ">")
	  if (_dynamicElementName)
		{
		  [_htmlBareStrings addObject:[NSString stringWithFormat:@"<%@",
												_dynamicElementName]];
		  [_elementsMap appendBytes:&ElementsMap_htmlBareString
						length:1];
		};

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
			  //TODOV
			  [_attributeAssociationsValues addObject:_association];
			  [_elementsMap appendBytes:&ElementsMap_attributeElement
							 length:1];
			  
			};
		};
	  _GSWebObjectsAssociationsCount=[self GSWebObjectsAssociationsCount];
	  if (_GSWebObjectsAssociationsCount>0)
		_hasGSWebObjectsAssociations=YES;
	  else
		_hasGSWebObjectsAssociations=[[self class]hasGSWebObjectsAssociations]; //return:YES
	  if (_hasGSWebObjectsAssociations)
		{
		  [_elementsMap appendBytes:&ElementsMap_gswebElement
						 length:1];
		};
	  [_htmlBareStrings addObject:@">"];
	  [_elementsMap appendBytes:&ElementsMap_htmlBareString
					 length:1];
	  if (_elements)
		{
		  int elementsN=[_elements count];
		  for(;elementsN>0;elementsN--)
			[_elementsMap appendBytes:&ElementsMap_dynamicElement
						   length:1];
		  if (_dynamicElementName)
			{
			  [_htmlBareStrings addObject:[NSString stringWithFormat:@"</%@>",
													_dynamicElementName]];
			  [_elementsMap appendBytes:&ElementsMap_htmlBareString
							length:1];
			};
		};
	  [self _initWithElementsMap:_elementsMap
			htmlBareStrings:_htmlBareStrings
			dynamicChildren:_elements
			attributeAssociations:_attributeAssociationsValues];
	};
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)_elementName
	 associations:(NSDictionary*)_associations
		 template:(GSWElement*)templateElement_
{
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"_elementName=[%@] _associations=[%@] templateElement_=[%@]",_elementName,_associations,templateElement_);
  //OK
  if ((self=[self initWithName:_elementName
				  associations:_associations
				  contentElements:templateElement_ ? [NSArray arrayWithObject:templateElement_] : nil]))
	{
	};
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(elementsMap);
  DESTROY(htmlBareStrings);
  DESTROY(dynamicChildren);
  DESTROY(attributeAssociations);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)_initWithElementsMap:(NSData*)_elementsMap
		  htmlBareStrings:(NSArray*)_htmlBareStrings
		   dynamicChildren:(NSArray*)_dynamicChildren
	 attributeAssociations:(NSArray*)attributeAssociations_
{
  BOOL _compactHTMLTags=NO;
  BOOL _hasGSWebObjectsAssociations=NO;
  int _GSWebObjectsAssociationsCount=0;
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"_elementsMap=%@ _htmlBareStrings:%@ _dynamicChildren=%@ attributeAssociations_=%@",
		_elementsMap,
		_htmlBareStrings,
		_dynamicChildren,
		attributeAssociations_);
  _compactHTMLTags=[self compactHTMLTags];
  //OK
  if (_compactHTMLTags)
	{
	  int elementN=0;
	  while(elementN<[_elementsMap length] && ((BYTE*)[_elementsMap bytes])[elementN]==ElementsMap_htmlBareString)
		elementN++;
	  NSDebugMLLog(@"gswdync",@"elementN=%d",elementN);
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
			  NSDebugMLLog(@"gswdync",@"rmString=%@ [_htmlBareStrings objectAtIndex:rmStringN]=%@",
					 rmString,
					 [_htmlBareStrings objectAtIndex:rmStringN]);
			  [rmString appendString:[_htmlBareStrings objectAtIndex:rmStringN]];
			};
		  [rmStrings addObject:rmString];
		  NSDebugMLLog(@"gswdync",@"rmStrings=%@",rmStrings);
		  for(rmStringN=elementN;rmStringN<[_htmlBareStrings count];rmStringN++)
			{
			  NSDebugMLLog(@"gswdync",@"rmStrings=%@ [_htmlBareStrings objectAtIndex:rmStringN]=%@",
					 rmStrings,
					 [_htmlBareStrings objectAtIndex:rmStringN]);
			  [rmStrings addObject:[_htmlBareStrings objectAtIndex:rmStringN]];
			};
		  _htmlBareStrings=rmStrings;
		  NSDebugMLLog(@"gswdync",@"_elementsMap=%@ _htmlBareStrings:%@",
				_elementsMap,
				_htmlBareStrings);
		};
	};
  [self setHtmlBareStrings:_htmlBareStrings]; 
  _GSWebObjectsAssociationsCount=[self GSWebObjectsAssociationsCount];
  if (_GSWebObjectsAssociationsCount>0)
	_hasGSWebObjectsAssociations=YES;
  else
	_hasGSWebObjectsAssociations=[[self class]hasGSWebObjectsAssociations];
  if (_hasGSWebObjectsAssociations)
	{
	  //TODO
	};
  
  ASSIGN(elementsMap,_elementsMap);
							  
  ASSIGN(dynamicChildren,_dynamicChildren);
  ASSIGN(attributeAssociations,attributeAssociations_);

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
  return dynamicChildren;
};

//--------------------------------------------------------------------
-(NSArray*)htmlBareStrings
{
  //OK
  return htmlBareStrings;
};

//--------------------------------------------------------------------
-(NSData*)elementsMap
{
  //OK
  return elementsMap;
};

//--------------------------------------------------------------------
-(NSArray*)attributeAssociations
{
  //OK
  return attributeAssociations;
};

//--------------------------------------------------------------------
-(void)_setEndOfHTMLTag:(unsigned int)_unknown
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
				   elementsMap,
				   htmlBareStrings,
				   dynamicChildren,
				   attributeAssociations];
};

//--------------------------------------------------------------------
-(void)setHtmlBareStrings:(NSArray*)_htmlBareStrings
{
  ASSIGN(htmlBareStrings,_htmlBareStrings);
};


@end

//====================================================================
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementA)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(unsigned int)GSWebObjectsAssociationsCount
{
  return 1;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStartC("GSWHTMLDynamicElement");
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
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
	  elementsFromIndex:(unsigned int)_fromIndex
				toIndex:(unsigned int)_toIndex
{
  //OK
  NSStringEncoding _encoding=0;
  NSArray* _dynamicChildren=nil;
  GSWComponent* _component=nil;
  GSWRequest* _request=nil;
  BOOL isFromClientComponent=NO;
  NSArray* _attributeAssociations=nil;
  int elementN=0;
  CONST BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[4]={0,0,0,0};
  BOOL inChildren=NO;
#ifndef NDEBUG
  NSString* debugElementID=nil;
#endif
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);

  _encoding=[response_ contentEncoding];
  _dynamicChildren=[self dynamicChildren];//call dynamicChildren //GSWTextField: nil
  NSDebugMLLog(@"gswdync",@"_dynamicChildren=%@",_dynamicChildren);
  _component=[context_ component];
  _request=[context_ request];
  isFromClientComponent=[_request isFromClientComponent]; //return NO
  _attributeAssociations=[self attributeAssociations]; //return nil for GSWTextField/GSWSubmitButton;


  NSAssert2(_fromIndex<[elementsMap length],@"_fromIndex out of range:%u (length=%d)",_fromIndex,[elementsMap length]);
  NSAssert2(_toIndex<[elementsMap length],@"_toIndex out of range:%u (length=%d)",_toIndex,[elementsMap length]);
  NSAssert2(_fromIndex<=_toIndex,@"_fromIndex>_toIndex %u %u ",_fromIndex,_toIndex);
  NSDebugMLLog(@"gswdync",@"Starting HTMLDyn AR ET=%@ id=%@",[self class],[context_ elementID]);
  for(elementN=0;elementN<=_toIndex;elementN++)
	{
	  element=(BYTE)elements[elementN];
	  NSDebugMLLog(@"gswdync",@"elements=%c",element);
	  if (element==ElementsMap_dynamicElement)
		{
		  if (!inChildren)
			{
#ifndef NDEBUG
			  debugElementID=[context_ elementID];
#endif
			  [context_ appendZeroElementIDComponent];
			  inChildren=YES;
			};
		}
	  else
		{
		  if (inChildren)
			{
			  [context_ deleteLastElementIDComponent];
			  inChildren=NO;
#ifndef NDEBUG
			  if (![debugElementID isEqualToString:[context_ elementID]])
				{
				  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
				  
				};
#endif
			};
		};

	  if (element==ElementsMap_htmlBareString)
		{
		  if (elementN>=_fromIndex)
			[response_ appendContentString:[htmlBareStrings objectAtIndex:elementsN[0]]];
		  elementsN[0]++;
		}
	  else if (element==ElementsMap_gswebElement)
		{
		  if (elementN>=_fromIndex)
			[self appendGSWebObjectsAssociationsToResponse:response_
				  inContext:context_];
		  elementsN[1]++;
		}
	  else if (element==ElementsMap_dynamicElement)
		{
		  if (elementN>=_fromIndex)
			{
			  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ [%s %d]",
					 [[_dynamicChildren objectAtIndex:elementsN[2]] class],
					 [context_ elementID],
					 __FILE__,__LINE__);
			  [[_dynamicChildren objectAtIndex:elementsN[2]] appendToResponse:response_
															 inContext:context_];
			  [context_ incrementLastElementIDComponent];
			};
		  elementsN[2]++;
		}
	  else if (element==ElementsMap_attributeElement)
		{
		  if (elementN>=_fromIndex)
			{
			  GSWAssociation* _association=[attributeAssociations objectAtIndex:elementsN[3]];
			  id _value=[_association valueInComponent:_component];
			  if (_value)
				{
				  [response_ appendContentString:@"=\""];
				  [response_ appendContentHTMLAttributeValue:_value];
				  [response_ appendContentString:@"\""];
				};
			};
		  elementsN[3]++;
		};
	};
  if (inChildren)
	{
	  [context_ deleteLastElementIDComponent];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
};


//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //???
  GSWElement* _element=nil;
  int elementN=0;
  NSArray* _dynamicChildren=[self dynamicChildren];
  CONST BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[4]={0,0,0,0};
  BOOL inChildren=NO;
#ifndef NDEBUG
  NSString* debugElementID=nil;
#endif
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  for(elementN=0;!_element && elementN<[elementsMap length];elementN++)
	{
	  element=(BYTE)elements[elementN];
	  if (element==ElementsMap_dynamicElement)
		{
		  if (!inChildren)
			{
#ifndef NDEBUG
			  debugElementID=[context_ elementID];
#endif
			  [context_ appendZeroElementIDComponent];
			  inChildren=YES;
			};
		}
	  else
		{
		  if (inChildren)
			{
			  [context_ deleteLastElementIDComponent];
			  inChildren=NO;
#ifndef NDEBUG
			  if (![debugElementID isEqualToString:[context_ elementID]])
				{
				  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
				  
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
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[_dynamicChildren objectAtIndex:elementsN[2]] class],[context_ elementID]);
		  _element=[[_dynamicChildren objectAtIndex:elementsN[2]] invokeActionForRequest:request_
																  inContext:context_];
		  [context_ incrementLastElementIDComponent];
		  elementsN[2]++;
		}
	  else if (element==ElementsMap_attributeElement)
		elementsN[3]++;
	};
  if (inChildren)
	{
	  [context_ deleteLastElementIDComponent];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStopC("GSWHTMLDynamicElement");
  return _element;
};


//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  int elementN=0;
  NSArray* _dynamicChildren=[self dynamicChildren];
  CONST BYTE* elements=[elementsMap bytes];
  BYTE element=0;
  int elementsN[4]={0,0,0,0};
  BOOL inChildren=NO;
#ifndef NDEBUG
  NSString* debugElementID=nil;
#endif
  LOGObjectFnStartC("GSWHTMLDynamicElement");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"Starting HTMLDyn TV ET=%@ id=%@",[self class],[context_ elementID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  for(elementN=0;elementN<[elementsMap length];elementN++)
	{
	  element=(BYTE)elements[elementN];
	  if (element==ElementsMap_dynamicElement)
		{
		  if (!inChildren)
			{
#ifndef NDEBUG
			  debugElementID=[context_ elementID];
#endif
			  [context_ appendZeroElementIDComponent];
			  inChildren=YES;
			};
		}
	  else
		{
		  if (inChildren)
			{
			  [context_ deleteLastElementIDComponent];
			  inChildren=NO;
#ifndef NDEBUG
			  if (![debugElementID isEqualToString:[context_ elementID]])
				{
				  NSDebugMLLog(@"gswdync",@"ERROR class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
				  
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
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[_dynamicChildren objectAtIndex:elementsN[2]] class],[context_ elementID]);
		  [[_dynamicChildren objectAtIndex:elementsN[2]] takeValuesFromRequest:request_
														 inContext:context_];
		  [context_ incrementLastElementIDComponent];
		  elementsN[2]++;
		}
	  else if (element==ElementsMap_attributeElement)
		elementsN[3]++;
	};
  if (inChildren)
	{
	  [context_ deleteLastElementIDComponent];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
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
@implementation GSWHTMLDynamicElement (GSWHTMLDynamicElementC)

//--------------------------------------------------------------------
+(void)setDynamicElementCompaction:(BOOL)_flag
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


