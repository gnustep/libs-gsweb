/** GSWHyperlink.m - <title>GSWeb: Class GSWHyperlink</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWHyperlink

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWHyperlink class])
    {
      standardClass=[GSWHyperlink class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

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

  _secure = [[anAssociationsDict objectForKey:secure__Key
                                             withDefaultObject:[_secure autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"secure=%@",_secure);

  _queryDictionary = [[anAssociationsDict objectForKey:queryDictionary__Key
                                          withDefaultObject:[_queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",_queryDictionary);

  _pathQueryDictionary = [[anAssociationsDict objectForKey:pathQueryDictionary__Key
                                              withDefaultObject:[_pathQueryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pathQueryDictionary=%@",_pathQueryDictionary);

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

      _urlPrefix = [[anAssociationsDict objectForKey:urlPrefix__Key
                                        withDefaultObject:[_urlPrefix autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"urlPrefix=%@",_urlPrefix);

      _escapeHTML = [[anAssociationsDict objectForKey:escapeHTML__Key
                                         withDefaultObject:[_escapeHTML autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"escapeHTML=%@",_escapeHTML);
    };


  tmpOtherAssociations=[NSMutableDictionary dictionaryWithDictionary:anAssociationsDict];
  [tmpOtherAssociations removeObjectForKey:action__Key];
  [tmpOtherAssociations removeObjectForKey:string__Key];
  [tmpOtherAssociations removeObjectForKey:pageName__Key];
  [tmpOtherAssociations removeObjectForKey:href__Key];
  [tmpOtherAssociations removeObjectForKey:disabled__Key];
  [tmpOtherAssociations removeObjectForKey:fragmentIdentifier__Key];
  [tmpOtherAssociations removeObjectForKey:secure__Key];
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
      [tmpOtherAssociations removeObjectForKey:urlPrefix__Key];
      [tmpOtherAssociations removeObjectForKey:pathQueryDictionary__Key];
      [tmpOtherAssociations removeObjectForKey:escapeHTML__Key];
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
    {
      ASSIGN(_otherQueryAssociations,([tmpOtherAssociations extractObjectsForKeysWithPrefix:@"?"
                                                            removePrefix:YES]));
      if ([_otherQueryAssociations count]==0)
        DESTROY(_otherQueryAssociations);

      if (!WOStrictFlag)
        {
          ASSIGN(_otherPathQueryAssociations,([tmpOtherAssociations extractObjectsForKeysWithPrefix:@"!"
                                                                    removePrefix:YES]));
          if ([_otherPathQueryAssociations count]==0)
            DESTROY(_otherPathQueryAssociations);
        };
    };
  NSDebugMLLog(@"gswdync",@"_otherQueryAssociations=%@",_otherQueryAssociations);
  NSDebugMLLog(@"gswdync",@"_otherPathQueryAssociations=%@",_otherPathQueryAssociations);

  ASSIGN(_otherAssociations,tmpOtherAssociations);
  NSDebugMLLog(@"gswdync",@"_otherAssociations=%@",_otherAssociations);

  if (!_action
      && !_href
      && !_pageName
      && !_directActionName
      && !_actionClass
      && !_redirectURL
      && !_filename
      && !_data)
    {
      NSString* parametersList=@"'action' or 'href' or 'pageName' or 'directActionName' or 'actionClass'";
      if (!WOStrictFlag)
        parametersList=[parametersList stringByAppendingFormat:@" or 'redirectURL' or 'filename' or 'data'"];
      ExceptionRaise(@"GSWHyperlink",
                     @"You need to specify at least %@ parameter",
                     parametersList);
    };

  if ([_action isValueConstant])
    {
      ExceptionRaise0(@"GSWHyperlink",
                     @"'action' parameter can't be a constant");
    };

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
  DESTROY(_secure);
  DESTROY(_queryDictionary);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_enabled);//GSWeb Only
  DESTROY(_displayDisabled);
  DESTROY(_redirectURL);
  DESTROY(_pageSetVarAssociations);//GNUstepWeb only
  DESTROY(_pageSetVarAssociationsDynamic);
  DESTROY(_otherQueryAssociations);
  DESTROY(_otherPathQueryAssociations);
  DESTROY(_otherAssociations);
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_urlPrefix);
  DESTROY(_escapeHTML);
  DESTROY(_pathQueryDictionary);
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
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK (pageName/action/directActionName)
  GSWComponent* component=GSWContext_component(aContext);
  BOOL disabledValue=NO;
  BOOL displayDisabledValue=YES;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStart();

  NS_DURING
    {
      GSWStartElement(aContext);
      GSWSaveAppendToResponseElementID(aContext);
      if (_disabled)
        {
          disabledValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                 standardEvaluateConditionInContextIMP,
                                                                 _disabled,aContext);
        }
      else if (_enabled)
        {
          disabledValue!=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                  standardEvaluateConditionInContextIMP,
                                                                  _enabled,aContext);
        };
      
      if (!WOStrictFlag && disabledValue && _displayDisabled)
        {
          displayDisabledValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                        standardEvaluateConditionInContextIMP,
                                                                        _displayDisabled,aContext);
        };
      if (!disabledValue)
        {
          GSWResponse_appendContentAsciiString(aResponse,@"<A href=\"");
          
          if (_href)
            {
              NSString* hrefValue=[self hrefInContext:aContext];
              GSWResponse_appendContentString(aResponse,hrefValue);
              if (!hrefValue)
                {
                  LOGSeriousError(@"href=%@ shouldn't return a nil value",_href);
                };
              NSDebugMLLog(@"gswdync",@"href=%@",_href);
              NSDebugMLLog(@"gswdync",@"hrefValue=%@",hrefValue);
              [self _appendQueryStringToResponse:aResponse
                    inContext:aContext];
              [self _appendFragmentToResponse:aResponse
                    inContext:aContext];
            }
          else if (_actionClass || _directActionName)
            {
              //OK
              [self _appendCGIActionURLToResponse:aResponse
                    inContext:aContext];
            }
          else if (_action || _pageName || _redirectURL)
            {
              //OK
              NSString* anUrl=nil;
              BOOL completeUrlsPreviousState=NO;
              BOOL isSecure=NO;
              BOOL requestIsSecure=[[aContext request]isSecure];
          
              if (_secure)
                {
                  isSecure=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                    standardEvaluateConditionInContextIMP,
                                                                    _secure,aContext);
                }
              else
                isSecure=requestIsSecure;

              // Force complete URLs
              if (isSecure!=requestIsSecure)
                completeUrlsPreviousState=[aContext _generateCompleteURLs];
              anUrl=(NSString*)[aContext componentActionURLIsSecure:isSecure];
              NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);
              GSWResponse_appendContentString(aResponse,anUrl);
              [self _appendQueryStringToResponse:aResponse
                    inContext:aContext];
              [self _appendFragmentToResponse:aResponse
                    inContext:aContext];
              if (isSecure!=requestIsSecure && !completeUrlsPreviousState)
                [aContext _generateRelativeURLs];
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
                  frameworkValue=[self frameworkNameInContext:aContext];
                  NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
                  request=[aContext request];
                  languages=[aContext languages];
                  anUrl=[resourceManager urlForResourceNamed:filenameValue
                                         inFramework:frameworkValue
                                         languages:languages
                                         request:request];
                };
              if (_key || _data)
                {
                  [urlValuedElementData appendDataURLToResponse:aResponse
                                        inContext:aContext];
                }
              else if (_filename)
                {
                  GSWResponse_appendContentString(aResponse,anUrl);
                };
            }
          else
            {		  
              [self _appendQueryStringToResponse:aResponse
                    inContext:aContext];
              [self _appendFragmentToResponse:aResponse
                    inContext:aContext];
            };
          GSWResponse_appendContentCharacter(aResponse,'"');
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
                  GSWResponse_appendContentCharacter(aResponse,' ');
                  GSWResponse_appendContentAsciiString(aResponse,aKey);
                  GSWResponse_appendContentCharacter(aResponse,'=');
                  GSWResponse_appendContentCharacter(aResponse,'"');
                  GSWResponse_appendContentHTMLString(aResponse,oaValue);
                  GSWResponse_appendContentCharacter(aResponse,'"');
                };
            };
          GSWResponse_appendContentCharacter(aResponse,'>');
        };
      if (!disabledValue || displayDisabledValue)
        {
          [self _appendChildrenToResponse:aResponse
                inContext:aContext];
        };
      if (!disabledValue)//??
        {
          GSWResponse_appendContentAsciiString(aResponse,@"</a>");
        };

      GSWStopElement(aContext);
      GSWAssertDebugElementIDsCount(aContext);
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWHyperlink appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWForm appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;

  LOGObjectFnStop();
};

//GSWeb Addintions {
//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)aContext
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=GSWContext_component(aContext);
  NSDebugMLog(@"framework=%@",_framework);
  if (_framework)
    frameworkName=[_framework valueInComponent:component];
  else
    frameworkName=[component frameworkName];
  return frameworkName;
};
// }
//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext
{
  //OK
  NSString* actionString=nil;
  NSDictionary* queryDictionary=nil;
  NSString* anUrl=nil;
  BOOL completeUrlsPreviousState=NO;
  BOOL isSecure=NO;
  BOOL requestIsSecure=NO;
  NSString* urlPrefix=nil;
  LOGObjectFnStart();

  actionString=[self computeActionStringInContext:aContext];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);

  queryDictionary=[self computeQueryDictionaryInContext:aContext];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);

  requestIsSecure=[[aContext request]isSecure];
  if (_secure)
    {
      isSecure=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                        standardEvaluateConditionInContextIMP,
                                                        _secure,aContext);
    }
  else
    isSecure=requestIsSecure;
  
  // Force complete URLs is secure mode is not the same
  if (isSecure!=requestIsSecure)
    completeUrlsPreviousState=[aContext _generateCompleteURLs];

  if (_urlPrefix)
    {
      GSWComponent* component=GSWContext_component(aContext);
      urlPrefix=[_urlPrefix valueInComponent:component];
      anUrl=(NSString*)[aContext directActionURLForActionNamed:actionString
                                urlPrefix:urlPrefix
                                queryDictionary:queryDictionary
                                isSecure:isSecure];
    }
  else
      anUrl=(NSString*)[aContext directActionURLForActionNamed:actionString
                                queryDictionary:queryDictionary
                                isSecure:isSecure];

  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);

  if (isSecure!=requestIsSecure && !completeUrlsPreviousState)
    [aContext _generateRelativeURLs];

  GSWResponse_appendContentString(aResponse,anUrl);

  [self _appendFragmentToResponse:aResponse
        inContext:aContext];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)computeActionStringInContext:(GSWContext*)aContext
{
  NSString* actionString=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_actionClass=%@",_actionClass);  
  NSDebugMLLog(@"gswdync",@"_directActionName=%@",_directActionName);  
  actionString=[(GSWHTMLDynamicElement*)self computeActionStringWithActionClassAssociation:_actionClass
                                        directActionNameAssociation:_directActionName
                                        pathQueryDictionaryAssociation:_pathQueryDictionary
                                        otherPathQueryAssociations:_otherPathQueryAssociations
                                        inContext:aContext];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);  
  LOGObjectFnStop();
  return actionString;
};

//--------------------------------------------------------------------
-(void)_appendQueryStringToResponse:(GSWResponse*)aResponse
                          inContext:(GSWContext*)aContext
{
  NSDictionary* queryDictionary=nil;
  LOGObjectFnStart();
  queryDictionary=[self computeQueryDictionaryInContext:aContext];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);  

  //TODOV
  if ([queryDictionary count]>0)
    {
      NSEnumerator* _enumerator = [queryDictionary keyEnumerator];
      id aKey=nil;
      id value=nil;
      BOOL first=YES;
      GSWResponse_appendContentCharacter(aResponse,'?');
      while ((aKey = [_enumerator nextObject]))
        {
          NSDebugMLLog(@"gswdync",@"aKey=%@",aKey);  
          if (first)
            first=NO;
          else
            GSWResponse_appendContentCharacter(aResponse,'&');
          GSWResponse_appendContentHTMLString(aResponse,aKey);
          value=[queryDictionary objectForKey:aKey];
          NSDebugMLLog(@"gswdync",@"value=%@",value);  
          value=[value description];
          NSDebugMLLog(@"gswdync",@"value=%@",value);  
          if ([value length]>0)
            {
              GSWResponse_appendContentCharacter(aResponse,'=');
              GSWResponse_appendContentHTMLString(aResponse,value);
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)aContext
{
  NSDictionary* queryDictionary=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_actionClass=%@",_actionClass);  
  NSDebugMLLog(@"gswdync",@"_directActionName=%@",_directActionName);  
  NSDebugMLLog(@"gswdync",@"_queryDictionary=%@",_queryDictionary);  
  NSDebugMLLog(@"gswdync",@"_otherQueryAssociations=%@",_otherQueryAssociations);
  queryDictionary=[(GSWHTMLDynamicElement*)self computeQueryDictionaryWithActionClassAssociation:_actionClass
                                           directActionNameAssociation:_directActionName
                                           queryDictionaryAssociation:_queryDictionary
                                           otherQueryAssociations:_otherQueryAssociations
                                           inContext:aContext];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);  
  LOGObjectFnStop();
  return queryDictionary;
};

//--------------------------------------------------------------------
-(void)_appendFragmentToResponse:(GSWResponse*)aResponse
                       inContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_fragmentIdentifier=%@",_fragmentIdentifier);
  if (_fragmentIdentifier)
    {
      id fragment=[_fragmentIdentifier valueInComponent:GSWContext_component(aContext)];
      NSDebugMLLog(@"gswdync",@"fragment=%@",fragment);
      if (fragment)
        {
          GSWResponse_appendContentCharacter(aResponse,'#');
          GSWResponse_appendContentString(aResponse,fragment);
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_appendContentStringToResponse:(GSWResponse*)aResponse
                            inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  if (_string)
    {
      id stringValue=nil;

      NSDebugMLLog(@"gswdync",@"string=%@",_string);
      stringValue=[_string valueInComponent:GSWContext_component(aContext)];
      NSDebugMLLog(@"gswdync",@"stringValue=%@",stringValue);

      if (stringValue)
        {
          BOOL escapeHTMLValue=YES;
          if (!WOStrictFlag && _escapeHTML)
            {
              escapeHTMLValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                       standardEvaluateConditionInContextIMP,
                                                                       _escapeHTML,aContext);
            };
          if (escapeHTMLValue)
            GSWResponse_appendContentHTMLString(aResponse,stringValue);
          else
            GSWResponse_appendContentString(aResponse,stringValue);
        };
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_appendChildrenToResponse:(GSWResponse*)aResponse
                       inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  [self _appendContentStringToResponse:aResponse
        inContext:aContext];
  NSDebugMLLog(@"gswdync",@"_children=%p",_children);
  if (_children)
    {
      GSWContext_appendZeroElementIDComponent(aContext);
      [_children appendToResponse:aResponse
                 inContext:aContext];
      GSWContext_deleteLastElementIDComponent(aContext);
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)hrefInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  NSString* hrefValue=nil;

  LOGObjectFnStart();

  component=GSWContext_component(aContext);
  hrefValue=[_href valueInComponent:component];

  LOGObjectFnStop();

  return hrefValue;
};
@end

//====================================================================
@implementation GSWHyperlink (GSWHyperlinkB)
//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  senderID=GSWContext_senderID(aContext);
  elementID=GSWContext_elementID(aContext);
  if ([elementID isEqualToString:senderID])
    {
      GSWComponent* component=GSWContext_component(aContext);
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
                  [(GSWComponent*)element ensureAwakeInContext:aContext];
                  /*
                    if (![_element aContext]) {
                    NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
                    [_element awakeInContext:aContext];
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
                          inContext:aContext];
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
                                         inContext:aContext];
          [redirectComponent setURL: (id)anUrl];
          element=redirectComponent;
        }
      else if (_href)
        {
          LOGSeriousError(@"We shouldn't come here (_href=%@)",_href);
        }
      else
        {
          //TODO
        };
      NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",element);
      //TODOV
      if (!element)
        element=[aContext page];
      //the end ?
    }
  else
    {
      if (_children)
        {
          GSWContext_appendZeroElementIDComponent(aContext);
          element=[_children invokeActionForRequest:request
                             inContext:aContext];
          GSWContext_deleteLastElementIDComponent(aContext);
        };
    };
  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke element=%@",element);
  NSDebugMLLog(@"gswdync",@"senderID=%@",GSWContext_senderID(aContext));

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStop();

  return element;
};


@end
