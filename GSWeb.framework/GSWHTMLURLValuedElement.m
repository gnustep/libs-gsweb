/** GSWHTMLURLValuedElement.m - <title>GSWeb: Class GSWHTMLURLValuedElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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
@implementation GSWHTMLURLValuedElement

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)inAssociations
  contentElements:(NSArray*)elements
{
  NSString* urlAttributeName=nil;
  NSString* valueAttributeName=nil;
  NSMutableDictionary* associations=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  urlAttributeName=[self urlAttributeName];//so what ?
  valueAttributeName=[self valueAttributeName];//so what ?

  associations=[NSMutableDictionary dictionaryWithDictionary:inAssociations];

  _src = [[inAssociations objectForKey:src__Key
                          withDefaultObject:[_src autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"src=%@",_src);

  _value = [[inAssociations objectForKey:value__Key
                            withDefaultObject:[_value autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"value=%@",_value);

  _pageName = [[inAssociations objectForKey:pageName__Key
                               withDefaultObject:[_pageName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pageName=%@",_pageName);

  _filename = [[inAssociations objectForKey:filename__Key
                               withDefaultObject:[_filename autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"filename=%@",_filename);

  _framework = [[inAssociations objectForKey:framework__Key
                                withDefaultObject:[_framework autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"framework=%@",_framework);

  _data = [[inAssociations objectForKey:data__Key
                           withDefaultObject:[_data autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"data=%@",_data);

  _mimeType = [[inAssociations objectForKey:mimeType__Key
                               withDefaultObject:[_mimeType autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"mimeType=%@",_mimeType);

  _key = [[inAssociations objectForKey:key__Key
                          withDefaultObject:[_key autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"key=%@",_key);

  _actionClass = [[inAssociations objectForKey:actionClass__Key
                                  withDefaultObject:[_actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionClass=%@",_actionClass);

  _directActionName = [[inAssociations objectForKey:directActionName__Key
                                       withDefaultObject:[_directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"directActionName=%@",_directActionName);

  _queryDictionary = [[inAssociations objectForKey:queryDictionary__Key
                                      withDefaultObject:[_queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",_queryDictionary);

  [associations removeObjectForKey:src__Key];
  [associations removeObjectForKey:value__Key];
  [associations removeObjectForKey:pageName__Key];
  [associations removeObjectForKey:filename__Key];
  [associations removeObjectForKey:framework__Key];
  [associations removeObjectForKey:data__Key];
  [associations removeObjectForKey:mimeType__Key];
  [associations removeObjectForKey:key__Key];
  [associations removeObjectForKey:actionClass__Key];
  [associations removeObjectForKey:directActionName__Key];
  [associations removeObjectForKey:queryDictionary__Key];
  if (!WOStrictFlag)
    {
  //pageSetVarAssociations//GNUstepWeb only      
      NSDictionary* pageSetVarAssociations=[inAssociations associationsWithoutPrefix:pageSetVar__Prefix__Key
                                                           removeFrom:associations];
	if ([pageSetVarAssociations count]>0)
          {
            ASSIGN(_pageSetVarAssociations,pageSetVarAssociations);
          };
	_pageSetVarAssociationsDynamic=[[inAssociations objectForKey:pageSetVars__Key
                                                        withDefaultObject:[_pageSetVarAssociationsDynamic autorelease]] retain];
	NSDebugMLLog(@"gswdync",@"_pageSetVarAssociationsDynamic=%@",_pageSetVarAssociationsDynamic);
	[associations removeObjectForKey:pageSetVars__Key];
    };
  if ((self=[super initWithName:[self elementName]//NEW
                   attributeAssociations:associations
                   contentElements:elements]))
    {
    };
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_src);
  DESTROY(_value);
  DESTROY(_pageName);
  DESTROY(_pageSetVarAssociations);//GNUstepWeb only
  DESTROY(_pageSetVarAssociationsDynamic);//GSWeb only
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_queryDictionary);
  DESTROY(_otherQueryAssociations);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)valueAttributeName
{
  //Does nothing
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)urlAttributeName
{
  //Does nothing
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

@end

//====================================================================
@implementation GSWHTMLURLValuedElement (GSWHTMLURLValuedElementA)

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[aContext elementID]);
  senderID=[aContext senderID];
  elementID=[aContext elementID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
  NSDebugMLLog(@"gswdync",@"[elementID isEqualToString:senderID]=%d",(int)[elementID isEqualToString:senderID]);
  if ([elementID isEqualToString:senderID])
    {
      GSWComponent* component=[aContext component];
      if (_value)
        element=[_value valueInComponent:component];
      else if (_pageName)
        {
          NSString* pageNameValue=[_pageName valueInComponent:component];
          element=[GSWApp pageWithName:pageNameValue
                          inContext:aContext];
          if (!WOStrictFlag && element)//GNUstepWeb only
            {
              if (_pageSetVarAssociations)
                {
                  [_pageSetVarAssociations associationsSetValuesFromObject:component
                                           inObject:(GSWComponent*)element];
                };
              if (_pageSetVarAssociationsDynamic)
                {
                  NSDictionary* assocs=[_pageSetVarAssociationsDynamic valueInComponent:component];
                  if (assocs)
                    {
                      if (![assocs isKindOfClass:[NSDictionary class]])
                        {
                          ExceptionRaise(@"GSWHTMLURLValuedElement",@"%@ (%@) must return a Dictionary, not a %@ like %@",
                                         pageSetVars__Key,
                                         _pageSetVarAssociationsDynamic,
                                         [assocs class],
                                         assocs);
                        }
                      else
                        {
                          [assocs associationsSetValuesFromObject:component
                                  inObject:(GSWComponent*)element];
                        };
                    };
                };
            };
        };
      NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke element=%@",element);
      //the end ?
      //TODOV
      if (!element)
        element=[aContext page];
    }
  else
    {
      element=[super invokeActionForRequest:aRequest
                     inContext:aContext];
    };
  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke element=%@",element);
  NSDebugMLLog(@"gswdync",@"senderID=%@",[aContext senderID]);
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[aContext elementID]);
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
  return element;
};


//====================================================================
@implementation GSWHTMLURLValuedElement (GSWHTMLURLValuedElementB)

//--------------------------------------------------------------------
//NDFN
-(void)appendURLToResponse:(GSWResponse*)aResponse
                 inContext:(GSWContext*)aContext
{
  //OK
  NSString* urlAttributeName=nil;
  NSString* url=nil;
  GSWComponent* component=nil;
  NSString* keyValue=nil;
  id data=nil;
  id mimeTypeValue=nil;
  GSWURLValuedElementData* dataValue=nil;
  GSWResourceManager* resourceManager=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  component=[aContext component];
  NSDebugMLLog(@"gswdync",@"data=%@",_data);
  NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
  NSDebugMLLog(@"gswdync",@"pageName=%@",_pageName);
  resourceManager=[[GSWApplication application]resourceManager];
  if (_src)
    url=[_src valueInComponent:component];
  else
    {
      if (_key)
        {
          keyValue=[_key valueInComponent:component];
          dataValue=[resourceManager _cachedDataForKey:keyValue];
        };
      if (!dataValue && _data)
        {
          data=[_data valueInComponent:component];  
          NSDebugMLLog(@"gswdync",@"_data=%@",data);
          mimeTypeValue=[_mimeType valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"mimeType=%@",_mimeType);
          NSDebugMLLog(@"gswdync",@"mimeTypeValue=%@",mimeTypeValue);
          dataValue=[[[GSWURLValuedElementData alloc] initWithData:data
                                                      mimeType:mimeTypeValue
                                                      key:nil] autorelease];
          NSDebugMLLog(@"gswdync",@"dataValue=%@",dataValue);
          [resourceManager setURLValuedElementData:dataValue];
        }
      else if (_filename)
        {
          //Exemple: Body with filename
          id filenameValue=nil;
          id frameworkValue=nil;
          GSWRequest* request=nil;
          NSArray* languages=nil;
          NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
          filenameValue=[_filename valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"filenameValue=%@",filenameValue);
          frameworkValue=[self frameworkNameInContext:aContext];
          NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
          request=[aContext request];
          languages=[aContext languages];
          url=[resourceManager urlForResourceNamed:filenameValue
                               inFramework:frameworkValue
                               languages:languages
                               request:request];
        };
    };
  [aResponse appendContentCharacter:' '];
  urlAttributeName=[self urlAttributeName];
  if (urlAttributeName)
    {
      [aResponse _appendContentAsciiString:urlAttributeName];
      [aResponse _appendContentAsciiString:@"=\""];
    };
  if (_src)
    {
      [aResponse appendContentString:url];
    }
  else
    {	
      if (_key || _data)
        {
          [dataValue appendDataURLToResponse:aResponse
                     inContext:aContext];
        }
      else if (_filename)
        {
          NSDebugMLLog(@"gswdync",@"url = %@",url);
          [aResponse appendContentString:url];
        }
      else
        {
          GSWDynamicURLString* componentActionURL=[aContext componentActionURL];
          NSDebugMLLog(@"gswdync",@"componentActionURL=%@",componentActionURL);
          [aResponse appendContentString:(NSString*)componentActionURL];
        };
    };
  if (urlAttributeName)
    [aResponse appendContentCharacter:'"'];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[aContext elementID]);
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  [self appendURLToResponse:aResponse
        inContext:aContext];
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(id)computeActionStringInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)computeQueryDictionaryInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)aContext
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=[aContext component];
  NSDebugMLog(@"framework=%@",_framework);
  if (_framework)
    frameworkName=[_framework valueInComponent:component];
  else
    frameworkName=[component frameworkName];
  return frameworkName;
};
@end
