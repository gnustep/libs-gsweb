/** GSWHTMLURLValuedElement.m - <title>GSWeb: Class GSWHTMLURLValuedElement</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
   $Revision$
   $Date$
   $Id$

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

static const char rcsId[] = "$Id$";

#include "GSWeb.h"
#include <gnustep/base/GSCategories.h>

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

  _src = [[associations objectForKey:src__Key
                          withDefaultObject:[_src autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"src=%@",_src);

  _value = [[associations objectForKey:value__Key
                            withDefaultObject:[_value autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"value=%@",_value);

  _pageName = [[associations objectForKey:pageName__Key
                               withDefaultObject:[_pageName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pageName=%@",_pageName);

  _filename = [[associations objectForKey:filename__Key
                               withDefaultObject:[_filename autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"filename=%@",_filename);

  _framework = [[associations objectForKey:framework__Key
                                withDefaultObject:[_framework autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"framework=%@",_framework);

  _data = [[associations objectForKey:data__Key
                           withDefaultObject:[_data autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"data=%@",_data);

  _mimeType = [[associations objectForKey:mimeType__Key
                               withDefaultObject:[_mimeType autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"mimeType=%@",_mimeType);

  _key = [[associations objectForKey:key__Key
                          withDefaultObject:[_key autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"key=%@",_key);

  _actionClass = [[associations objectForKey:actionClass__Key
                                  withDefaultObject:[_actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionClass=%@",_actionClass);

  _directActionName = [[associations objectForKey:directActionName__Key
                                       withDefaultObject:[_directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"directActionName=%@",_directActionName);

  _queryDictionary = [[associations objectForKey:queryDictionary__Key
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
      NSDictionary* pageSetVarAssociations=[associations associationsWithoutPrefix:pageSetVar__Prefix__Key
                                                           removeFrom:associations];
	if ([pageSetVarAssociations count]>0)
          {
            ASSIGN(_pageSetVarAssociations,pageSetVarAssociations);
          };
	_pageSetVarAssociationsDynamic=[[associations objectForKey:pageSetVars__Key
                                                        withDefaultObject:[_pageSetVarAssociationsDynamic autorelease]] retain];
	NSDebugMLLog(@"gswdync",@"_pageSetVarAssociationsDynamic=%@",_pageSetVarAssociationsDynamic);

        _cidStore = [[associations objectForKey:cidStore__Key
                                   withDefaultObject:[_cidStore autorelease]] retain];
        NSDebugMLLog(@"gswdync",@"cidStore=%@",_cidStore);
  
        _cidKey = [[associations objectForKey:cidKey__Key
                                 withDefaultObject:[_cidKey autorelease]] retain];
        NSDebugMLLog(@"gswdync",@"cidKey=%@",_cidKey);
  

	[associations removeObjectForKey:pageSetVars__Key];
	[associations removeObjectForKey:cidStore__Key];
	[associations removeObjectForKey:cidKey__Key];
    };

  if ([associations count]>0)
    {
      ASSIGN(_otherQueryAssociations,([associations extractObjectsForKeysWithPrefix:@"?"
                                                    removePrefix:YES]));
      if ([_otherQueryAssociations count]==0)
        DESTROY(_otherQueryAssociations);
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
  DESTROY(_cidStore);//GSWeb only
  DESTROY(_cidKey);//GSWeb only
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

@end

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
  id cidStoreValue=nil;
  GSWURLValuedElementData* dataValue=nil;
  GSWResourceManager* resourceManager=nil;

  LOGObjectFnStartC("GSWHTMLURLValuedElement");  
NS_DURING
  {
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  component=[aContext component];
  NSDebugMLLog(@"gswdync",@"data=%@",_data);
  NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
  NSDebugMLLog(@"gswdync",@"pageName=%@",_pageName);

  cidStoreValue=[_cidStore valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"cidStoreValue=%@",cidStoreValue);

  resourceManager=[[GSWApplication application]resourceManager];

  if (_src)
    {
      url=[_src valueInComponent:component];      
      NSDebugMLLog(@"gswdync",@"url=%@",url);
      if (cidStoreValue)
        {
          url=[self addURL:url
                    forCIDStore:_cidStore
                    inContext:aContext];
          NSDebugMLLog(@"gswdync",@"url=%@",url);
        };
    }
  else if (_actionClass || _directActionName)
    {
      url=(NSString*)[aContext componentActionURL];
      NSDebugMLLog(@"gswdync",@"url=%@",url);
      if (cidStoreValue)
        {
          url=[self addURL:url
                    forCIDStore:_cidStore
                    inContext:aContext];
          NSDebugMLLog(@"gswdync",@"url=%@",url);
        };
    }
  else
    {
      BOOL processed=NO;
      if (_key)
        {
          keyValue=[_key valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"keyValue=%@",keyValue);
          dataValue=[resourceManager _cachedDataForKey:keyValue];
          NSDebugMLLog(@"gswdync",@"dataValue=%@",dataValue);
        };
      if (_data && !dataValue)
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
          processed=YES;
        }
      if (cidStoreValue && dataValue)
        {
          url=[self addURLValuedElementData:dataValue
                    forCIDStore:_cidStore
                    inContext:aContext];
          NSDebugMLLog(@"gswdync",@"url=%@",url);
        }
      if (!processed && _filename)
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
          if (cidStoreValue)
            {
              NSString* path=[resourceManager pathForResourceNamed:filenameValue
                                              inFramework:frameworkValue
                                              languages:languages];
              url=[self addPath:path
                        forCIDStore:_cidStore
                        inContext:aContext];
              NSDebugMLLog(@"gswdync",@"url=%@",url);
            }
          else
            {
              url=[resourceManager urlForResourceNamed:filenameValue
                                   inFramework:frameworkValue
                                   languages:languages
                                   request:request];
              NSDebugMLLog(@"gswdync",@"url=%@",url);
            };
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
  else if (_actionClass || _directActionName)
    {
      [aResponse appendContentString:url];
    }
  else
    {	
      if (_key || _data)
        {
          if (cidStoreValue)
            [aResponse appendContentString:url];
          else
            [dataValue appendDataURLToResponse:aResponse
                       inContext:aContext];
        }
      else if (_filename)
        {
          NSDebugMLLog(@"gswdync",@"url = %@",url);
          [aResponse appendContentString:url];
        };
    };
  if (urlAttributeName)
    [aResponse appendContentCharacter:'"'];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[aContext elementID]);
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWHTMLURLValuedElement appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWHTMLURLValuedElement appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;
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
  //OK
  NSString* actionString=nil;
  NSDictionary* queryDictionary=nil;
  NSString* anUrl=nil;
  LOGObjectFnStart();

  actionString=[self computeActionStringInContext:aContext];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);

  queryDictionary=[self computeQueryDictionaryInContext:aContext];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);

  anUrl=(NSString*)[aContext directActionURLForActionNamed:actionString
                             queryDictionary:queryDictionary];
  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);

  [aResponse appendContentString:anUrl];

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)computeActionStringInContext:(GSWContext*)aContext
{
  NSString* actionString=nil;
  LOGObjectFnStart();
  actionString=[self computeActionStringWithActionClassAssociation:_actionClass
                     directActionNameAssociation:_directActionName
                     inContext:aContext];
  LOGObjectFnStop();
  return actionString;
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)aContext
{
  NSDictionary* queryDictionary=nil;
  LOGObjectFnStart();
  queryDictionary=[self computeQueryDictionaryWithActionClassAssociation:_actionClass
                        directActionNameAssociation:_directActionName
                        queryDictionaryAssociation:_queryDictionary
                        otherQueryAssociations:_otherQueryAssociations
                        inContext:aContext];
  LOGObjectFnStop();
  return queryDictionary;
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

//====================================================================
@implementation GSWHTMLURLValuedElement (GSWHTMLURLValuedElementCID)


-(NSString*)addCIDElement:(NSDictionary*)cidElement
                   forKey:(NSString*)cidKeyValue
                forCIDStore:(GSWAssociation*)cidStore
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
      cidObject=[_cidStore valueInComponent:component];
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
         forCIDStore:(GSWAssociation*)cidStore
         inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (url && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[_cidKey valueInComponent:component];
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
                   forCIDStore:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};


//--------------------------------------------------------------------
-(NSString*)addURLValuedElementData:(GSWURLValuedElementData*)data
                        forCIDStore:(GSWAssociation*)cidStore
                          inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (data && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[_cidKey valueInComponent:component];
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
                   forCIDStore:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};


//--------------------------------------------------------------------
-(NSString*)addPath:(NSString*)path
        forCIDStore:(GSWAssociation*)cidStore
          inContext:(GSWContext*)aContext
{
  NSString* newURL=nil;
  LOGObjectFnStart();
  if (path && cidStore)
    {
      NSString* cidKeyValue=nil;
      GSWComponent* component=[aContext component];
      cidKeyValue=(NSString*)[_cidKey valueInComponent:component];
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
                   forCIDStore:cidStore
                   inContext:aContext];
    }
  LOGObjectFnStop();
  return newURL;
};

@end
