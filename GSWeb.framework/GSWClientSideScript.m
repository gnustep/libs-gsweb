/** GSWClientSideScript.m - <title>GSWeb: Class GSWClientSideScript</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

//====================================================================
@implementation GSWClientSideScript

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWClientSideScript");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ templateElement=%@",aName,associations,templateElement);
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
      NSDebugMLLog(@"gswdync",@"GSWClientSideScript: scriptFile=%@",_scriptFile);
      _scriptString = [[associations objectForKey:scriptString__Key
                                     withDefaultObject:[_scriptString autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWClientSideScript: scriptString=%@",_scriptString);
      _scriptSource = [[associations objectForKey:scriptSource__Key
                                     withDefaultObject:[_scriptSource autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWClientSideScript: scriptSource=%@",_scriptSource);
      _hideInComment = [[associations objectForKey:hideInComment__Key
                                      withDefaultObject:[_hideInComment autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWClientSideScript: hideInComment=%@",_hideInComment);
      _language = [[associations objectForKey:language__Key
                                 withDefaultObject:[_language autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWClientSideScript: language=%@",_language);
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
  LOGObjectFnStartC("GSWClientSideScript");
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);
  component=[aContext component];
  [super appendToResponse:aResponse
         inContext:aContext];
  //hideInCommentValue=[_hideInComment valueInComponent:component];
  hideInCommentValue=[self evaluateCondition:_hideInComment
                           inContext:aContext];
  [aResponse _appendContentAsciiString:@"<SCRIPT language="];
  languageValue=[_language valueInComponent:component];

  [aResponse appendContentHTMLAttributeValue:languageValue];
  if ([_otherAttributes count]>0)
  {
    NSEnumerator* enumerator = [_otherAttributes keyEnumerator];
    id key;
    id value;
    while ((key = [enumerator nextObject]))
      {
        value=[_otherAttributes objectForKey:key];
        [aResponse appendContentCharacter:' '];
        [aResponse appendContentString:key];
        if (value)
          {
            [aResponse appendContentCharacter:'='];
            [aResponse appendContentHTMLAttributeValue:value];
          };
      };
  };
  if (_scriptSource)
    {
      scriptValue=[_scriptSource valueInComponent:component];
      if (scriptValue)
        {
          [aResponse appendContentString:@" src=\""];
          [aResponse appendContentString:scriptValue];
          [aResponse appendContentCharacter:'"'];
        };
    }
  [aResponse appendContentCharacter:'>'];
  if (_scriptString || _scriptFile)
    {
      [aResponse appendContentCharacter:'\n'];
      if (hideInCommentValue)
        [aResponse _appendContentAsciiString:@"<!-- GNUstepWeb ClientScript\n"];
      
      if (_scriptString)
        {
          scriptValue=[_scriptString valueInComponent:component];
          if (scriptValue)
            [aResponse appendContentString:scriptValue];
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
                      [aResponse appendContentString:scriptValue];
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
                   LOGException(@"GSWClientSideScript exception=%@",exception);                   
                   [exception raise];
                };
            }
          else
            {
              //TODO
            };
        };
      
      [aResponse appendContentCharacter:'\n'];
      if (hideInCommentValue)
        [aResponse _appendContentAsciiString:@"//-->\n"];
    };
  [aResponse _appendContentAsciiString:@"</SCRIPT>"];
  GSWStopElement(aContext);
  LOGObjectFnStopC("GSWClientSideScript");
};

//--------------------------------------------------------------------
@end

