/** GSWHyperlink.m - <title>GSWeb: Class GSWHyperlink</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
@implementation GSWHyperlink

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)anAssociationsDict
         template:(GSWElement*)templateElement
{
  //OK
  NSMutableDictionary* tmpOtherAssociations=nil;
  LOGObjectFnStart();
  ASSIGN(_children,templateElement);
  _action = [[anAssociationsDict objectForKey:action__Key
                                 withDefaultObject:[_action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"action=%@",_action);

  _string = [[anAssociationsDict objectForKey:string__Key
                                 withDefaultObject:[_string autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"string=%@",_string);

  _pageName = [[anAssociationsDict objectForKey:pageName__Key
                                   withDefaultObject:[_pageName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pageName=%@",_pageName);

  _href = [[anAssociationsDict objectForKey:href__Key
                               withDefaultObject:[_href autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"href=%@",_href);

  _disabled = [[anAssociationsDict objectForKey:disabled__Key
                                   withDefaultObject:[_disabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"disabled=%@",_disabled);

  _fragmentIdentifier = [[anAssociationsDict objectForKey:fragmentIdentifier__Key
                                             withDefaultObject:[_fragmentIdentifier autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"fragmentIdentifier=%@",_fragmentIdentifier);

  _queryDictionary = [[anAssociationsDict objectForKey:queryDictionary__Key
                                          withDefaultObject:[_queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",_queryDictionary);

  _actionClass = [[anAssociationsDict objectForKey:actionClass__Key
                                      withDefaultObject:[_actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionClass=%@",_actionClass);

  _directActionName = [[anAssociationsDict objectForKey:directActionName__Key
                                           withDefaultObject:[_directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"directActionName=%@",_directActionName);

  if (!WOStrictFlag)
    {
      _enabled = [[anAssociationsDict objectForKey:enabled__Key
                                      withDefaultObject:[_enabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"enabled=%@",_enabled);
      if (_disabled && _enabled)
	{
	  ExceptionRaise(@"GSWHyperlink",@"You can't specify 'disabled' and 'enabled' together. componentAssociations:%@",
                         anAssociationsDict);
	};
      
      _displayDisabled = [[anAssociationsDict objectForKey:displayDisabled__Key
                                              withDefaultObject:[_displayDisabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"displayDisabled=%@",_displayDisabled);
      
      _redirectURL = [[anAssociationsDict objectForKey:redirectURL__Key
                                          withDefaultObject:[_redirectURL autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"redirectURL=%@",_redirectURL);
  
      _filename = [[anAssociationsDict objectForKey:filename__Key
                                       withDefaultObject:[_filename autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
      
      _framework = [[anAssociationsDict objectForKey:framework__Key
                                        withDefaultObject:[_framework autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"framework=%@",_framework);

      _data = [[anAssociationsDict objectForKey:data__Key
                                   withDefaultObject:[_data autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"data=%@",_data);
      
      _mimeType = [[anAssociationsDict objectForKey:mimeType__Key
                                       withDefaultObject:[_mimeType autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"mimeType=%@",_mimeType);
      
      _key = [[anAssociationsDict objectForKey:key__Key
                                  withDefaultObject:[_key autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"key=%@",_key);
    };

  tmpOtherAssociations=[NSMutableDictionary dictionaryWithDictionary:anAssociationsDict];
  [tmpOtherAssociations removeObjectForKey:action__Key];
  [tmpOtherAssociations removeObjectForKey:string__Key];
  [tmpOtherAssociations removeObjectForKey:pageName__Key];
  [tmpOtherAssociations removeObjectForKey:href__Key];
  [tmpOtherAssociations removeObjectForKey:disabled__Key];
  [tmpOtherAssociations removeObjectForKey:fragmentIdentifier__Key];
  [tmpOtherAssociations removeObjectForKey:queryDictionary__Key];
  [tmpOtherAssociations removeObjectForKey:actionClass__Key];
  [tmpOtherAssociations removeObjectForKey:directActionName__Key];
  if (!WOStrictFlag)
    {
      [tmpOtherAssociations removeObjectForKey:enabled__Key];
      [tmpOtherAssociations removeObjectForKey:redirectURL__Key];
    
      [tmpOtherAssociations removeObjectForKey:filename__Key];
      [tmpOtherAssociations removeObjectForKey:framework__Key];
      [tmpOtherAssociations removeObjectForKey:data__Key];
      [tmpOtherAssociations removeObjectForKey:mimeType__Key];
      [tmpOtherAssociations removeObjectForKey:key__Key];
    };

  if (!WOStrictFlag)
    //pageSetVarAssociations//GNUstepWeb only
    {
      NSDictionary* tmpPageSetVarAssociations=[anAssociationsDict associationsWithoutPrefix:pageSetVar__Prefix__Key
                                                                  removeFrom:tmpOtherAssociations];
      if ([tmpPageSetVarAssociations count]>0)
        _pageSetVarAssociations=[tmpPageSetVarAssociations retain];
      NSDebugMLLog(@"gswdync",@"_pageSetVarAssociations=%@",_pageSetVarAssociations);
      
      _pageSetVarAssociationsDynamic=[[anAssociationsDict objectForKey:pageSetVars__Key
                                                          withDefaultObject:[_pageSetVarAssociationsDynamic autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"pageSetVarAssociationsDynamic=%@",_pageSetVarAssociationsDynamic);
      [tmpOtherAssociations removeObjectForKey:pageSetVars__Key];
    };

  if ([tmpOtherAssociations count]>0)
    _otherAssociations=[[NSDictionary dictionaryWithDictionary:tmpOtherAssociations] retain];

  NSDebugMLLog(@"gswdync",@"_otherAssociations=%@",_otherAssociations);
  //TODO NSDictionary* otherQueryAssociations;

  if ((self=[super initWithName:aName
                   associations:nil
                   template:nil]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_string);
  DESTROY(_pageName);
  DESTROY(_href);
  DESTROY(_disabled);
  DESTROY(_fragmentIdentifier);
  DESTROY(_queryDictionary);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_enabled);//GSWeb Only
  DESTROY(_displayDisabled);
  DESTROY(_redirectURL);
  DESTROY(_pageSetVarAssociations);//GNUstepWeb only
  DESTROY(_pageSetVarAssociationsDynamic);
  DESTROY(_otherQueryAssociations);
  DESTROY(_otherAssociations);
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_children);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

@end

//====================================================================
@implementation GSWHyperlink (GSWHyperlinkA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK (pageName/action/directActionName)
  GSWComponent* component=[context component];
  BOOL disabledValue=NO;
  BOOL displayDisabledValue=YES;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);
  if (_disabled)
    disabledValue=[self evaluateCondition:_disabled
                        inContext:context];
  else if (_enabled)
    disabledValue=![self evaluateCondition:_enabled
                         inContext:context];

  if (!WOStrictFlag && _disabled && _displayDisabled)
    {
      displayDisabledValue=[self evaluateCondition:_displayDisabled
                                 inContext:context];
    };
  if (!disabledValue)
    {
      [response _appendContentAsciiString:@"<A "];
      [response _appendContentAsciiString:@"href"];
      [response appendContentCharacter:'='];
      [response appendContentCharacter:'"'];
      if (_directActionName)
        {
          //OK
          [self _appendCGIActionURLToResponse:response
                inContext:context];
        }
      else if (_action || _pageName || _redirectURL)
        {
          NSString* anUrl=(NSString*)[context componentActionURL];
          NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);
          [response appendContentString:anUrl];
          [self _appendQueryStringToResponse:response
                inContext:context];
        }
      else if (_href)
        {
          NSString* hrefValue=[self hrefInContext:context];
          [response appendContentString:hrefValue];
          if (!hrefValue)
            {
              LOGSeriousError(@"href=%@ shouldn't return a nil value",_href);
            };
          NSDebugMLLog(@"gswdync",@"href=%@",_href);
          NSDebugMLLog(@"gswdync",@"hrefValue=%@",hrefValue);
        }
      else if (!WOStrictFlag && (_filename || _data))
        {
          NSString* anUrl=nil;
          NSString* keyValue=nil;
          id dataValue=nil;
          id mimeTypeValue=nil;
          GSWURLValuedElementData* urlValuedElementData=nil;
          GSWResourceManager* resourceManager=nil;
          resourceManager=[[GSWApplication application]resourceManager];
          if (_key)
            {
              keyValue=[_key valueInComponent:component];
              urlValuedElementData=[resourceManager _cachedDataForKey:keyValue];
            };
          if (!urlValuedElementData && _data)
            {
              dataValue=[_data valueInComponent:component];  
              NSDebugMLLog(@"gswdync",@"dataValue=%@",dataValue);
              mimeTypeValue=[_mimeType valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"mimeType=%@",_mimeType);
              NSDebugMLLog(@"gswdync",@"mimeTypeValue=%@",mimeTypeValue);
              urlValuedElementData=[[[GSWURLValuedElementData alloc] initWithData:dataValue
                                                                     mimeType:mimeTypeValue
                                                                     key:nil] autorelease];
              NSDebugMLLog(@"gswdync",@"urlValuedElementData=%@",urlValuedElementData);
              [resourceManager setURLValuedElementData:urlValuedElementData];
            }
          else if (_filename)
            {
              id filenameValue=nil;
              id frameworkValue=nil;
              GSWRequest* request=nil;
              NSArray* languages=nil;
              NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
              filenameValue=[_filename valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"filenameValue=%@",filenameValue);
              frameworkValue=[self frameworkNameInContext:context];
              NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
              request=[context request];
              languages=[context languages];
              anUrl=[resourceManager urlForResourceNamed:filenameValue
                                     inFramework:frameworkValue
                                     languages:languages
                                     request:request];
            };
          if (_key || _data)
            {
              [urlValuedElementData appendDataURLToResponse:response
                                    inContext:context];
            }
          else if (_filename)
            {
              [response appendContentString:anUrl];
            };
        }
      else
        {		  
          LOGObjectFnNotImplemented();	//TODOFN
        };
      [response appendContentCharacter:'"'];
      NSDebugMLLog(@"gswdync",@"otherAssociations=%@",_otherAssociations);
      if (_otherAssociations)
        {
          NSEnumerator *enumerator = [_otherAssociations keyEnumerator];
          id aKey=nil;
          id oaValue=nil;
          while ((aKey = [enumerator nextObject]))
            {
              NSDebugMLLog(@"gswdync",@"aKey=%@",aKey);
              oaValue=[[_otherAssociations objectForKey:aKey] valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"oaValue=%@",oaValue);
              [response appendContentCharacter:' '];
              [response _appendContentAsciiString:aKey];
              [response appendContentCharacter:'='];
              [response appendContentCharacter:'"'];
              [response appendContentHTMLString:oaValue];
              [response appendContentCharacter:'"'];
            };
        };
      [response appendContentCharacter:'>'];
    };
  if (!disabledValue || displayDisabledValue)
    {
      if (_string)
        {
          id stringValue=nil;
          NSDebugMLLog(@"gswdync",@"string=%@",_string);
          stringValue=[_string valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"stringValue=%@",stringValue);
          if (stringValue)
            [response appendContentHTMLString:stringValue];
        };
      if (_children)
        {
          [context appendZeroElementIDComponent];
          [_children appendToResponse:response
                     inContext:context];
          [context deleteLastElementIDComponent];
        };
    };
  if (!disabledValue)//??
    {
      [response _appendContentAsciiString:@"</a>"];
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWHyperlink appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//GSWeb Addintions {
//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)context
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=[context component];
  NSDebugMLog(@"framework=%@",_framework);
  if (_framework)
    frameworkName=[_framework valueInComponent:component];
  else
    frameworkName=[component frameworkName];
  return frameworkName;
};
// }
//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)context
{
  //OK
  NSString* actionString=nil;
  NSDictionary* queryDictionary=nil;
  NSString* anUrl=nil;
  LOGObjectFnStart();
  actionString=[self computeActionStringInContext:context];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);
  queryDictionary=[self computeQueryDictionaryInContext:context];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);
  anUrl=(NSString*)[context directActionURLForActionNamed:actionString
                            queryDictionary:queryDictionary];
  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);
  [response appendContentString:anUrl];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)computeActionStringInContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  id tmpDirectActionString=nil;
  id directActionNameValue=nil;
  id actionClassValue=nil;
  LOGObjectFnStart();
  component=[context component];
  if (_directActionName)
    directActionNameValue=[_directActionName valueInComponent:component];
  if (_actionClass)
    actionClassValue=[_actionClass valueInComponent:component];

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

  NSDebugMLLog(@"gswdync",@"tmpDirectActionString=%@",tmpDirectActionString);
  LOGObjectFnStop();
  return tmpDirectActionString;
};

//--------------------------------------------------------------------
-(void)_appendQueryStringToResponse:(GSWResponse*)response
                          inContext:(GSWContext*)context
{
  //OK
  NSDictionary* queryDictionary=nil;
  LOGObjectFnStart();
  queryDictionary=[self computeQueryDictionaryInContext:context];

  //TODOV
  if (queryDictionary && [queryDictionary count]>0)
    {
      NSEnumerator* _enumerator = [queryDictionary keyEnumerator];
      id aKey=nil;
      id value=nil;
      BOOL first=YES;
      [response appendContentCharacter:'?'];
      while ((aKey = [_enumerator nextObject]))
        {
          if (first)
            first=NO;
          else
            [response appendContentCharacter:'&'];
          [response appendContentHTMLString:aKey];
          value=[queryDictionary objectForKey:aKey];
          value=[value description];
          if ([value length]>0)
            {
              [response appendContentCharacter:'='];
              [response appendContentHTMLString:value];
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context
{
  //OK
  NSMutableDictionary* queryDictionary=nil;
  GSWComponent* component=nil;
  GSWSession* session=nil;
  LOGObjectFnStart();
  queryDictionary=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  component=[context component];
  session=[context existingSession];
  if (session)
    {
      if (!_action && !_pageName
          && (WOStrictFlag || (!WOStrictFlag && !_redirectURL))) //??
        {
          NSString* sessionID=[session sessionID];
          [queryDictionary setObject:sessionID
                           forKey:GSWKey_SessionID[GSWebNamingConv]];
        };
    };
  //TODOV
  if (_otherQueryAssociations)
    {
      NSEnumerator *enumerator = [_otherQueryAssociations keyEnumerator];
      id oaKey=nil;
      while ((oaKey = [enumerator nextObject]))
        {
          id oaValue=[[_otherQueryAssociations objectForKey:oaKey] valueInComponent:component];
          if (!oaValue)
            oaValue=[NSString string];
          [queryDictionary setObject:oaValue
                           forKey:oaKey];
        };
    };
  if (_queryDictionary)
    {
      NSEnumerator *enumerator = nil;
      NSDictionary* queryDictionaryValue=[_queryDictionary valueInComponent:component];
      id oaKey;

      NSAssert3(!queryDictionaryValue || [queryDictionaryValue isKindOfClass:[NSDictionary class]],
                @"queryDictionary value is not a dictionary but a %@. association was: %@. queryDictionaryValue is:",
                [queryDictionaryValue class],
                _queryDictionary,
                queryDictionaryValue);

      enumerator = [queryDictionaryValue keyEnumerator];

      while ((oaKey = [enumerator nextObject]))
        {
          id oaValue=[queryDictionaryValue objectForKey:oaKey];
          if (!oaValue)
            oaValue=@"";
          [queryDictionary setObject:oaValue
                           forKey:oaKey];
        };
    };
  //TODO finished ??
  LOGObjectFnStop();
  return queryDictionary;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)hrefInContext:(GSWContext*)context
{
  GSWComponent* component=nil;
  NSString* hrefValue=nil;
  component=[context component];
  hrefValue=[_href valueInComponent:component];
  return hrefValue;
};
@end

//====================================================================
@implementation GSWHyperlink (GSWHyperlinkB)
//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  senderID=[context senderID];
  elementID=[context elementID];
  if ([elementID isEqualToString:senderID])
    {
      GSWComponent* component=[context component];
      if (_action)
        {
          NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke action=%@",_action);
          element=[_action valueInComponent:component];
          if (element)
            {
              if (![element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
                {
                  ExceptionRaise0(@"GSWHyperlink",@"Invoked element return a not GSWComponent element");
                } 
              else 
                {
                  // call awakeInContext when _element is sleeping deeply
                  [element ensureAwakeInContext:context];
                  /*
                    if (![_element context]) {
                    NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
                    [_element awakeInContext:context];
                    }
                  */
                }
            };
        }
      else if (_pageName)
        {
          id pageNameValue=nil;
          pageNameValue=[_pageName valueInComponent:component];
          element=[GSWApp pageWithName:pageNameValue
                          inContext:context];
          NSDebugMLLog(@"gswdync",@"element=%@",element);
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
                          ExceptionRaise(@"GSWHyperlink",@"%@ (%@) must return a Dictionary, not a %@ like %@",
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
        }
      else if (!WOStrictFlag && _redirectURL) //GNUstepWeb only
        {
          NSString* anUrl=[_redirectURL valueInComponent:component];
          id redirectComponent = [GSWApp pageWithName:@"GSWRedirect"
                                         inContext:context];
          [redirectComponent setURL:anUrl];
          element=redirectComponent;
        }
      else if (_href)
        {
          LOGSeriousError(@"We shouldn't come here (href=%@)",href);
        }
      else
        {
          //TODO
        };
      NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",element);
      //TODOV
      if (!element)
        element=[context page];
      //the end ?
    }
  else
    {
      if (_children)
        {
          [context appendZeroElementIDComponent];
          element=[_children invokeActionForRequest:request
                             inContext:context];
          [context deleteLastElementIDComponent];
        };
    };
  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke element=%@",element);
  NSDebugMLLog(@"gswdync",@"senderID=%@",[context senderID]);
  NSDebugMLLog(@"gswdync",@"elementID=%@",[context elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ definition name=%@ id=%@",
               [self class],[self definitionName],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWHyperlink invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};


@end
