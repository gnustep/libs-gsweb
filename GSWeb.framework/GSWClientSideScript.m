/** GSWClientSideScript.m - <title>GSWeb: Class GSWClientSideScript</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        May 1999
      
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


static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWClientSideScript

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWClientSideScript class])
    {
      standardClass=[GSWClientSideScript class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];

  [tmpAssociations removeObjectForKey:scriptFile__Key];
  [tmpAssociations removeObjectForKey:scriptString__Key];
  [tmpAssociations removeObjectForKey:scriptSource__Key];
  [tmpAssociations removeObjectForKey:hideInComment__Key];
  [tmpAssociations removeObjectForKey:language__Key];
  _otherAttributes=[NSDictionary dictionaryWithDictionary:tmpAssociations];
  RETAIN(_otherAttributes);
  if ((self=[super initWithName:aName
                   associations:nil
                   template:templateElement]))
    {
      _scriptFile = [[associations objectForKey:scriptFile__Key
                                   withDefaultObject:[_scriptFile autorelease]] retain];

      _scriptString = [[associations objectForKey:scriptString__Key
                                     withDefaultObject:[_scriptString autorelease]] retain];

      _scriptSource = [[associations objectForKey:scriptSource__Key
                                     withDefaultObject:[_scriptSource autorelease]] retain];

      _hideInComment = [[associations objectForKey:hideInComment__Key
                                      withDefaultObject:[_hideInComment autorelease]] retain];

      _language = [[associations objectForKey:language__Key
                                 withDefaultObject:[_language autorelease]] retain];

    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_scriptFile);
  DESTROY(_scriptString);
  DESTROY(_scriptSource);
  DESTROY(_hideInComment);
  DESTROY(_language);
  DESTROY(_otherAttributes);
  [super dealloc];
};

//--------------------------------------------------------------------

@end

//====================================================================
@implementation GSWClientSideScript (GSWClientSideScriptA)
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  BOOL hideInCommentValue=NO;
  id languageValue=nil;
  id scriptValue=nil;

  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);
  component=GSWContext_component(aContext);
  [super appendToResponse:aResponse
         inContext:aContext];
  //hideInCommentValue=[_hideInComment valueInComponent:component];
  hideInCommentValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                              standardEvaluateConditionInContextIMP,
                                                              _hideInComment,aContext);
  GSWResponse_appendContentAsciiString(aResponse,@"<SCRIPT language=");
  languageValue=[_language valueInComponent:component];

  GSWResponse_appendContentHTMLAttributeValue(aResponse,languageValue);
  if ([_otherAttributes count]>0)
  {
    NSEnumerator* enumerator = [_otherAttributes keyEnumerator];
    id key;
    id value;
    while ((key = [enumerator nextObject]))
      {
        value=[_otherAttributes objectForKey:key];
        GSWResponse_appendContentCharacter(aResponse,' ');
        GSWResponse_appendContentString(aResponse,key);
        if (value)
          {
            GSWResponse_appendContentCharacter(aResponse,'=');
            GSWResponse_appendContentHTMLAttributeValue(aResponse,value);
          };
      };
  };
  if (_scriptSource)
    {
      scriptValue=[_scriptSource valueInComponent:component];
      if (scriptValue)
        {
          GSWResponse_appendContentString(aResponse,@" src=\"");
          GSWResponse_appendContentString(aResponse,scriptValue);
          GSWResponse_appendContentCharacter(aResponse,'"');
        };
    }
  GSWResponse_appendContentCharacter(aResponse,'>');
  if (_scriptString || _scriptFile)
    {
      GSWResponse_appendContentCharacter(aResponse,'\n');
      if (hideInCommentValue)
        GSWResponse_appendContentAsciiString(aResponse,@"<!-- GNUstepWeb ClientScript\n");
      
      if (_scriptString)
        {
          scriptValue=[_scriptString valueInComponent:component];
          if (scriptValue)
            GSWResponse_appendContentString(aResponse,scriptValue);
          else
            {
              //TODO
            };
        }
      else if (_scriptFile)
        {
          NSString* scriptFileName=[_scriptFile valueInComponent:component];
          if (scriptFileName)
            {
              GSWResourceManager* resourceManager=nil;
              NSString* path=nil;
              resourceManager=[GSWApp resourceManager];
              path=[resourceManager pathForResourceNamed:scriptFileName
                                    inFramework:nil
                                    languages:[aContext languages]];
              if (path)
                {
                  NSString* scriptValue=nil;
                  scriptValue=[NSString stringWithContentsOfFile:path];
                  if (scriptValue)
                    {
                      GSWResponse_appendContentString(aResponse,scriptValue);
                    }
                  else
                    {
                      //TODO
                    }
                }
              else
                {
                   NSException* exception=nil;
                   exception=[NSException exceptionWithName:NSInvalidArgumentException
                                          reason:[NSString stringWithFormat:
                                                             @"Can't find script file '%@'",
                                                           scriptFileName]
                                          userInfo:nil];
                   [exception raise];
                };
            }
          else
            {
              //TODO
            };
        };
      
      GSWResponse_appendContentCharacter(aResponse,'\n');
      if (hideInCommentValue)
        GSWResponse_appendContentAsciiString(aResponse,@"//-->\n");
    };
  GSWResponse_appendContentAsciiString(aResponse,@"</SCRIPT>");
  GSWStopElement(aContext);
};

//--------------------------------------------------------------------
@end

