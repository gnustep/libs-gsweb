/** GSWTemplateParserANTLR.h - <title>GSWeb: Class GSWTemplateParserANTLR</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:       Mar 1999
   
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

#include "GSWeb.h"
#include "GSWTemplateParserANTLR.h"

//====================================================================
@implementation GSWTemplateParserANTLR
-(void)dealloc
{
  DESTROY(_tagsNames);
  DESTROY(_tagsAttrs);
  [super dealloc];
};
-(NSArray*)templateElements
{
  NSArray* elements=nil;
  id<NSObject,ANTLRAST> htmlAST=nil;
  NSAutoreleasePool* arpParse=nil;
  ANTLRTextInputStreamString* htmlStream=nil;
  GSWHTMLLexer* htmlLexer=nil;
  ANTLRTokenBuffer* htmlTokenBuffer=nil;
  GSWHTMLParser* htmlParser=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"template named:%@ frameworkName:%@ pageDefString=%@",
               _templateName,
               _frameworkName,
               _definitionsString);
  //TODO remove
  /*
    [ANTLRCharBuffer setTraceFlag_LA:YES];
    [ANTLRCharScanner setTraceFlag_LA:YES];
    [ANTLRLLkParser setTraceFlag_LA:YES];
    [ANTLRTokenBuffer setTraceFlag_LA:YES];
  */
  htmlStream=[[ANTLRTextInputStreamString newWithString:_string]
               autorelease];
  htmlLexer=[[[GSWHTMLLexer alloc]initWithTextStream:htmlStream]
              autorelease];
  htmlTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:htmlLexer];
  htmlParser=[[[GSWHTMLParser alloc] initWithTokenBuffer:htmlTokenBuffer]
               autorelease];
  NSDebugMLLog(@"low",@"template named:%@ HTMLString=%@",
               _templateName,
               _string);
  arpParse=[NSAutoreleasePool new];
  NS_DURING
    {
      [htmlParser document];
      if ([htmlParser isError])
        {
          LOGError(@"Parser Errors : %@",[htmlParser errors]);
          ExceptionRaise(@"GSWTemplateParser",
                         @"GSWTemlateParser: Errors in HTML parsing template named %@: %@\nAST:\n%@",
                         _templateName,
                         [htmlParser errors],
                         [htmlParser AST]);
        };
      htmlAST=[htmlParser AST];
      NSDebugMLLog0(@"low",@"HTML Parse OK!");
    }
  NS_HANDLER
    {
      LOGError(@"template named:%@ HTML Parse failed!",_templateName);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,@"In [htmlParser document]... template named:%@ HTML Parse failed!",_templateName);
      [localException retain];
      DESTROY(arpParse);
      [localException autorelease];
      [localException raise];
    }
  NS_ENDHANDLER;
  NSDebugMLLog0(@"low",@"arpParse infos:\n");
#ifndef NDEBUG
  if ([NSThread currentThread])
    {
      NSDebugMLLog(@"low",@"thread current_pool=%@",
                   [NSThread currentThread]->_autorelease_vars.current_pool);
      NSDebugMLLog(@"low",@"thread current_pool _parentAutoreleasePool=%@",
                   [[NSThread currentThread]->_autorelease_vars.current_pool _parentAutoreleasePool]);
    };
#endif
  NSDebugMLLog0(@"low",@"DESTROY(arpParse)\n");
  [htmlAST retain];
  DESTROY(arpParse);
  arpParse=[NSAutoreleasePool new];
  [htmlAST autorelease];
  NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");
  if (htmlAST)
    {
      _tagsNames=[[NSMutableDictionary dictionary] retain];
      _tagsAttrs=[[NSMutableDictionary dictionary] retain];
      NS_DURING
        {
          elements=[self createElementsStartingWithAST:&htmlAST
                         stopOnTagNamed:nil];
          NSDebugMLLog(@"low",@"template named:%@ _template=%@",
                       _templateName,
                       elements);
        }
      NS_HANDLER
        {
          LOGSeriousError(@"template named:%@ createElements failed!",
                          _templateName);
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In createElementsStartingWithAST...");
          [localException raise];
        }
      NS_ENDHANDLER;
    };
  NSDebugMLLog0(@"low",@"ARP infos:\n");
#ifndef NDEBUG
  if ([NSThread currentThread])
    {
      NSDebugMLLog(@"low",@"thread current_pool=%@",
                   [NSThread currentThread]->_autorelease_vars.current_pool);
      NSDebugMLLog(@"low",@"thread current_pool _parentAutoreleasePool=%@",
                   [[NSThread currentThread]->_autorelease_vars.current_pool _parentAutoreleasePool]);
    };
#endif
  [elements retain];
  NSDebugMLLog0(@"low",@"DESTROY(arp)\n");
  DESTROY(arpParse);
  NSDebugMLLog0(@"low",@"DESTROYED(arp)\n");
  [elements autorelease];
  NSDebugMLLog0(@"low",@"Display Template\n");
  NSDebugMLLog(@"low",@"template named:%@ elements=%@",
               _templateName,
               elements);
  LOGClassFnStop();
  return elements;
};

//--------------------------------------------------------------------
-(BOOL)parseTag:(ANTLRDefAST)anAST
{
  BOOL htmlAttrParseOK=YES;
  NSString* tagName=[_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
  LOGClassFnStart();
  if (!tagName
      && ([anAST tokenType]==GSWHTMLTokenType_OPENTAG
          || [anAST tokenType]==GSWHTMLTokenType_CLOSETAG))
    {
      NSAutoreleasePool* arpParse=nil;
      ANTLRTextInputStreamString* _tagStream=[[[ANTLRTextInputStreamString alloc] 
                                                initWithString:[anAST text]]
                                               autorelease];
      GSWHTMLAttrLexer* htmlAttrLexer=[[[GSWHTMLAttrLexer alloc]
                                         initWithTextStream:_tagStream]
                                        autorelease];
      ANTLRTokenBuffer* htmlAttrTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:htmlAttrLexer];
      GSWHTMLAttrParser* _tagParser=[[[GSWHTMLAttrParser alloc] initWithTokenBuffer:htmlAttrTokenBuffer]
                                      autorelease];
      NSString* tagName=nil;
      NSDictionary* tagAttrs=nil;
      NSDebugMLLog(@"low",@"PARSE:[%@]",[anAST text]);
      NSDebugMLLog(@"low",@"stream:[%@]",_tagStream);
      htmlAttrParseOK=NO;	  
      arpParse=[NSAutoreleasePool new];
      NS_DURING
        {
          [_tagParser tag];
          if ([_tagParser isError])
            {
              LOGError(@"Parser Errors : %@",[_tagParser errors]);
              ExceptionRaise(@"GSWTemplateParser",
                             @"GSWTemlateParser: Errors in HTML Tag parsing: %@",
                             [_tagParser errors]);
            };
          tagName=[_tagParser tagName];
          tagAttrs=[_tagParser attributes];
          NSDebugMLLog(@"low",@"tagName=%@ tagAttrs=%@",
                       tagName,
                       tagAttrs);
          htmlAttrParseOK=YES;
        }
      NS_HANDLER
        {
          htmlAttrParseOK=NO;
          LOGError(@"PARSE PB:[%@]",[anAST text]);//TODO
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In [_tagParser tag]...");
          [localException raise];
        }
      NS_ENDHANDLER;
      NSDebugMLLog0(@"low",@"arpParse infos:\n");
#ifndef NDEBUG
      if ([NSThread currentThread])
        {
          NSDebugMLLog(@"low",@"thread current_pool=%@",
                       [NSThread currentThread]->_autorelease_vars.current_pool);
          NSDebugMLLog(@"low",@"thread current_pool _parentAutoreleasePool=%@",
                       [[NSThread currentThread]->_autorelease_vars.current_pool _parentAutoreleasePool]);
        };
#endif
      NSDebugMLLog0(@"low",@"DESTROY(arpParse)\n");
      DESTROY(arpParse);
      NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");

      NSDebugMLLog(@"low",@"END PARSE:[%@]",[anAST text]);
	  
      if (htmlAttrParseOK && tagName)
        {
          NSDebugMLLog(@"low",@"tagName:[%@]",tagName);
          if ([tagName hasPrefix:@"\""] && [tagName hasSuffix:@"\""])
            tagName=[[tagName stringByDeletingPrefix:@"\""]stringByDeletingSuffix:@"\""];
          NSDebugMLLog(@"low",@"Add tagName:[%@]",
                       tagName);
          [_tagsNames setObject:tagName
                     forKey:[NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
          NSDebugMLLog(@"low",@"Verify tagName=%@",
                       [_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)anAST]]); //TODO bad hack
          NSDebugMLLog(@"low",@"Add tagsAttrs:[%@]",
                       tagAttrs);
          if (tagAttrs)
            {
              [_tagsAttrs setObject:tagAttrs
                         forKey:[NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
              NSDebugMLLog(@"low",@"Verify tagAttrs=%@",
                           [_tagsAttrs objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)anAST]]); //TODO bad hack
            };
        };
    };
  LOGClassFnStop();
  return htmlAttrParseOK;
};

//--------------------------------------------------------------------
-(NSString*)getTagNameFor:(ANTLRDefAST)anAST
{
  NSString* tagName=[_tagsNames objectForKey:
                                  [NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[anAST text]);
  if (!tagName)
    {
      BOOL htmlAttrParseOK=[self parseTag:anAST];
      if (htmlAttrParseOK)
        tagName=[_tagsNames objectForKey:
                              [NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
    };
  NSDebugMLLog(@"low",@"tagName:[%@]",tagName);
  LOGClassFnStop();
  return tagName;
};

//--------------------------------------------------------------------
-(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)anAST
{
  NSDictionary* tagAttrs=[_tagsAttrs objectForKey:
                                       [NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[anAST text]);
  if (!tagAttrs)
    {
      BOOL htmlAttrParseOK=[self parseTag:anAST];
      if (htmlAttrParseOK)
        tagAttrs=[_tagsAttrs objectForKey:
                               [NSNumber numberWithUnsignedLong:(unsigned long)anAST]]; //TODO bad hack
    };
  NSDebugMLLog(@"low",@"tagAttrs:[%@]",tagAttrs);
  LOGClassFnStop();
  return tagAttrs;
};

//--------------------------------------------------------------------
-(NSArray*)createElementsStartingWithAST:(ANTLRDefAST*)anAST
                          stopOnTagNamed:(NSString*)stopTagName
{
  NSMutableArray* elements=[NSMutableArray array];
  ANTLRDefAST currentAST=*anAST;
  BOOL end=NO;
  BOOL inHTMLBareString=NO;
  NSMutableString* htmlBareString=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"stopTagName:[%@]",stopTagName);
  while(currentAST && !end)
    {
      GSWElement* element=nil;
      NSString* tagName=nil;
      NSDictionary* tagAttrs=nil;
      BOOL stopBareString=NO;
      NSDebugMLLog(@"low",@"[currentAST: text=[%@] Type=%d",
                   [currentAST text],
                   [currentAST tokenType]);
      NSDebugMLLog(@"low",@"end=%s inHTMLBareString=%s stopBareString=%s",
                   end ? "YES" : "NO",
                   inHTMLBareString ? "YES" : "NO",
                   stopBareString ? "YES" : "NO");

      if ([currentAST tokenType]==GSWHTMLTokenType_OPENTAG
          || [currentAST tokenType]==GSWHTMLTokenType_CLOSETAG)
        {
          tagName=[self getTagNameFor:currentAST];
          NSDebugMLLog(@"low",@"Result tagName:[%@]",tagName);
          if (!tagName)
            {
              LOGError0(@"");//TODO
            }
          else
            {
              NSDebugMLLog(@"low",@"[currentAST tokenType]=%d",(int)[currentAST tokenType]);
              if ([currentAST tokenType]==GSWHTMLTokenType_OPENTAG)
                {
                  NSDebugMLLog0(@"low",@"Found Open Tag");
                  tagAttrs=[self getTagAttrsFor:currentAST];
                  NSDebugMLLog(@"low",@"tagAttrs=%@",tagAttrs);
                  if ([tagName caseInsensitiveCompare:GSWTag_Name[GSWNAMES_INDEX]]==NSOrderedSame
                      || [tagName caseInsensitiveCompare:GSWTag_Name[WONAMES_INDEX]]==NSOrderedSame)
                    {
                      NSDebugMLLog0(@"low",@"Found GSWeb Tag");
                      NSDebugMLLog(@"low",@"tagAttrs=%@",
                                   tagAttrs);
                      if (inHTMLBareString)
                        {
                          NSDebugMLLog0(@"low",@"==>Stop BareString");
                          stopBareString=YES;
                        }
                      else
                        {
                          ANTLRDefAST nextAST=[currentAST nextSibling];
                          NSString* name=[tagAttrs objectForKey:@"name"];
                          NSDebugMLLog0(@"low",@"Process GSWeb Tag");
                          NSDebugMLLog(@"low",@"GSWeb Tag: name:[%@]",
                                       name);
                          if (!name)
                            {
                              LOGError(@"No name for Element:%@",
                                       [currentAST text]);//TODO
                              ExceptionRaise(@"GSWTemplateParser",
                                             @"GSWTemlateParser: no name for GNUstepWeb tag in template named %@",
                                             _templateName);
                            }
                          else
                            {
                              GSWPageDefElement* pageDefElement=[_definitions objectForKey:name];
                              NSDebugMLLog(@"low",@"pageDefElement:[%@]",
                                           pageDefElement);
                              NSDebugMLLog(@"low",@"GSWeb Tag pageDefElement:[%@]",
                                           pageDefElement);
                              if (pageDefElement)
                                {
                                  NSDictionary* _associations=[pageDefElement associations];
                                  NSString* className=nil;
                                  className=[pageDefElement className];
                                  NSDebugMLLog(@"low",@"GSWeb Tag className:[%@]",
                                               className);
                                  if (className)
                                    {
                                      NSArray* children=nil;
                                      children=[self createElementsStartingWithAST:&nextAST
                                                     stopOnTagNamed:tagName];
                                      NSDebugMLLog(@"low",@"CREATE Element of Class:%@",className);
                                      NSDebugMLLog(@"low",@"children:%@",children);
                                      NSDebugMLLog(@"low",@"associations:%@",_associations);
                                      {
                                        NSEnumerator* _tagAttrsEnum = [tagAttrs keyEnumerator];
                                        id _tagAttrKey=nil;
                                        id _tagAttrValue=nil;
                                        NSMutableDictionary* _addedAssoc=nil;
                                        while ((_tagAttrKey = [_tagAttrsEnum nextObject]))
                                          {
                                            if (![_tagAttrKey isEqualToString:@"name"]
                                                && ![_associations objectForKey:_tagAttrKey])
                                              {
                                                if (!_addedAssoc)
                                                  _addedAssoc=[NSMutableDictionary dictionary];
                                                _tagAttrValue=[tagAttrs objectForKey:_tagAttrKey];
                                                [_addedAssoc setObject:[GSWAssociation associationWithValue:_tagAttrValue]
                                                             forKey:_tagAttrKey];
                                              };
                                          };
                                        if (_addedAssoc)
                                          {
                                            _associations=[_associations dictionaryByAddingEntriesFromDictionary:_addedAssoc];
                                          };
                                      };
                                      element=[GSWApp dynamicElementWithName:className
                                                      associations:_associations
                                                      template:[[[GSWHTMLStaticGroup alloc]initWithContentElements:children]autorelease]
                                                      languages:_languages];
                                      if (element)
                                        [element setDefinitionName:[pageDefElement elementName]];
                                      else
                                        {
                                          ExceptionRaise(@"GSWTemplateParser",
                                                         @"GSWTemplateParser: Creation failed for element named:%@ className:%@ in template named %@",
                                                         [pageDefElement elementName],
                                                         className,
                                                         _templateName);
                                        };
                                    }
                                  else
                                    {
                                      ExceptionRaise(@"GSWTemplateParser",
                                                     @"GSWTemplateParser: No class name in page definition for tag named:%@ pageDefElement=%@ in template named %@",
                                                     name,
                                                     pageDefElement,
                                                     _templateName);
                                    };
                                }
                              else
                                {
                                  ExceptionRaise(@"GSWTemplateParser",
                                                 @"No element definition for tag named:%@ in template named %@",
                                                 name,
                                                 _templateName);
                                };
                            };
                          currentAST=nextAST;
                        };
                    };
                }
              else
                {				  
                  if (stopTagName
                      && [tagName caseInsensitiveCompare:stopTagName]==NSOrderedSame)
                    {
                      NSDebugMLLog(@"low",@"stopTagName found: %@",stopTagName);
                      end=YES;
                      stopBareString=YES;
                      currentAST=[currentAST nextSibling];
                    };
                };
            };
        }
      else if ([currentAST tokenType]==GSWHTMLTokenType_COMMENT)
        {
          stopBareString=YES;
          element=[GSWHTMLComment elementWithString:[currentAST text]];
          currentAST=[currentAST nextSibling];
        }
      NSDebugMLLog(@"low",@"end=%s inHTMLBareString=%s stopBareString=%s",
                   end ? "YES" : "NO",
                   inHTMLBareString ? "YES" : "NO",
                   stopBareString ? "YES" : "NO");
      if (!element && !end && !stopBareString)
        {
          NSDebugMLLog0(@"low",@"!element && !end && !stopBareString");
          if (!inHTMLBareString)
            {
              NSDebugMLLog0(@"low",@"!inHTMLBareString ==> inHTMLBareString=YES");
              inHTMLBareString=YES;
              htmlBareString=[[NSMutableString new] autorelease];
            };
          NSDebugMLLog(@"low",@"inHTMLBareString: adding [%@]",[currentAST text]);
          if ([currentAST tokenType]==GSWHTMLTokenType_OPENTAG)
            [htmlBareString appendFormat:@"<%@>",[currentAST text]];
          else if ([currentAST tokenType]==GSWHTMLTokenType_CLOSETAG)
            [htmlBareString appendFormat:@"</%@>",[currentAST text]];
          else
            [htmlBareString appendString:[currentAST text]];
          NSDebugMLLog(@"low",@"htmlBareString: ==> [%@]",htmlBareString);
          currentAST=[currentAST nextSibling];
        };
      if (inHTMLBareString && (stopBareString || !currentAST))
        {
          NSDebugMLLog0(@"low",@"inHTMLBareString && stopBareString");
          NSDebugMLLog(@"low",@"CREATE GSWHTMLBareString:\n%@",htmlBareString);
          element=[GSWHTMLBareString elementWithString:htmlBareString];
          NSDebugMLLog(@"low",@"element:%@",element);
          htmlBareString=nil;
          inHTMLBareString=NO;
        };
      if (element)
        {
          NSDebugMLLog(@"low",@"element to add: element=[%@]",element);
          [elements addObject:element];
          element=nil;
        };
      NSDebugMLLog(@"low",@"element:%@",element);
      NSDebugMLLog(@"low",@"inHTMLBareString:%d",(int)inHTMLBareString);
      NSDebugMLLog(@"low",@"htmlBareString:%@",htmlBareString);
    };
  *anAST=currentAST;
  NSDebugMLLog(@"low",@"elements]:%@",elements);
  LOGClassFnStop();
  return elements;
};

@end

