/* GSWTemplateParserANTLR.m - GSWeb: Class GSWTemplateParserANTLR
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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
-(BOOL)parseTag:(ANTLRDefAST)_AST
{
  BOOL htmlAttrParseOK=YES;
  NSString* tagName=[_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  if (!tagName
      && ([_AST tokenType]==GSWHTMLTokenType_OPENTAG
          || [_AST tokenType]==GSWHTMLTokenType_CLOSETAG))
    {
      NSAutoreleasePool* arpParse=nil;
      ANTLRTextInputStreamString* _tagStream=[[[ANTLRTextInputStreamString alloc] 
                                                initWithString:[_AST text]]
                                               autorelease];
      GSWHTMLAttrLexer* htmlAttrLexer=[[[GSWHTMLAttrLexer alloc]
                                         initWithTextStream:_tagStream]
                                        autorelease];
      ANTLRTokenBuffer* htmlAttrTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:htmlAttrLexer];
      GSWHTMLAttrParser* _tagParser=[[[GSWHTMLAttrParser alloc] initWithTokenBuffer:htmlAttrTokenBuffer]
                                      autorelease];
      NSString* tagName=nil;
      NSDictionary* tagAttrs=nil;
      NSDebugMLLog(@"low",@"PARSE:[%@]",[_AST text]);
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
          LOGError(@"PARSE PB:[%@]",[_AST text]);//TODO
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

      NSDebugMLLog(@"low",@"END PARSE:[%@]",[_AST text]);
	  
      if (htmlAttrParseOK && tagName)
        {
          NSDebugMLLog(@"low",@"tagName:[%@]",tagName);
          if ([tagName hasPrefix:@"\""] && [tagName hasSuffix:@"\""])
            tagName=[[tagName stringWithoutPrefix:@"\""]stringWithoutSuffix:@"\""];
          NSDebugMLLog(@"low",@"Add tagName:[%@]",
                       tagName);
          [_tagsNames setObject:tagName
                     forKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
          NSDebugMLLog(@"low",@"Verify tagName=%@",
                       [_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]); //TODO bad hack
          NSDebugMLLog(@"low",@"Add tagsAttrs:[%@]",
                       tagAttrs);
          if (tagAttrs)
            {
              [_tagsAttrs setObject:tagAttrs
                         forKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
              NSDebugMLLog(@"low",@"Verify tagAttrs=%@",
                           [_tagsAttrs objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]); //TODO bad hack
            };
        };
    };
  LOGClassFnStop();
  return htmlAttrParseOK;
};

//--------------------------------------------------------------------
-(NSString*)getTagNameFor:(ANTLRDefAST)_AST
{
  NSString* tagName=[_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[_AST text]);
  if (!tagName)
    {
      BOOL htmlAttrParseOK=[self parseTag:_AST];
      if (htmlAttrParseOK)
        tagName=[_tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
    };
  NSDebugMLLog(@"low",@"tagName:[%@]",tagName);
  LOGClassFnStop();
  return tagName;
};

//--------------------------------------------------------------------
-(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)_AST
{
  NSDictionary* tagAttrs=[_tagsAttrs objectForKey:
                                       [NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[_AST text]);
  if (!tagAttrs)
    {
      BOOL htmlAttrParseOK=[self parseTag:_AST];
      if (htmlAttrParseOK)
        tagAttrs=[_tagsAttrs objectForKey:
                               [NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
    };
  NSDebugMLLog(@"low",@"tagAttrs:[%@]",tagAttrs);
  LOGClassFnStop();
  return tagAttrs;
};

//--------------------------------------------------------------------
-(NSArray*)createElementsStartingWithAST:(ANTLRDefAST*)_AST
                          stopOnTagNamed:(NSString*)_stopTagName
{
  NSMutableArray* _elements=[NSMutableArray array];
  ANTLRDefAST _currentAST=*_AST;
  BOOL end=NO;
  BOOL inHTMLBareString=NO;
  NSMutableString* htmlBareString=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"_stopTagName:[%@]",_stopTagName);
  while(_currentAST && !end)
    {
      GSWElement* element=nil;
      NSString* tagName=nil;
      NSDictionary* tagAttrs=nil;
      BOOL stopBareString=NO;
      NSDebugMLLog(@"low",@"[_currentAST: text=[%@] Type=%d",
                   [_currentAST text],
                   [_currentAST tokenType]);
      NSDebugMLLog(@"low",@"end=%s inHTMLBareString=%s stopBareString=%s",
                   end ? "YES" : "NO",
                   inHTMLBareString ? "YES" : "NO",
                   stopBareString ? "YES" : "NO");

      if ([_currentAST tokenType]==GSWHTMLTokenType_OPENTAG
          || [_currentAST tokenType]==GSWHTMLTokenType_CLOSETAG)
        {
          tagName=[self getTagNameFor:_currentAST];
          NSDebugMLLog(@"low",@"Result tagName:[%@]",tagName);
          if (!tagName)
            {
              LOGError0(@"");//TODO
            }
          else
            {
              NSDebugMLLog(@"low",@"[_currentAST tokenType]=%d",(int)[_currentAST tokenType]);
              if ([_currentAST tokenType]==GSWHTMLTokenType_OPENTAG)
                {
                  NSDebugMLLog0(@"low",@"Found Open Tag");
                  tagAttrs=[self getTagAttrsFor:_currentAST];
                  NSDebugMLLog(@"low",@"tagAttrs=%@",tagAttrs);
                  if ([tagName caseInsensitiveCompare:@"gsweb"]==NSOrderedSame
                      || [tagName caseInsensitiveCompare:@"webobject"]==NSOrderedSame)
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
                          ANTLRDefAST nextAST=[_currentAST nextSibling];
                          NSString* name=[tagAttrs objectForKey:@"name"];
                          NSDebugMLLog0(@"low",@"Process GSWeb Tag");
                          NSDebugMLLog(@"low",@"GSWeb Tag: name:[%@]",
                                       name);
                          if (!name)
                            {
                              LOGError(@"No name for Element:%@",
                                       [_currentAST text]);//TODO
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
                                      if (!element)
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
                          _currentAST=nextAST;
                        };
                    };
                }
              else
                {				  
                  if (_stopTagName
                      && [tagName caseInsensitiveCompare:_stopTagName]==NSOrderedSame)
                    {
                      NSDebugMLLog(@"low",@"_stopTagName found: %@",_stopTagName);
                      end=YES;
                      stopBareString=YES;
                      _currentAST=[_currentAST nextSibling];
                    };
                };
            };
        }
      else if ([_currentAST tokenType]==GSWHTMLTokenType_COMMENT)
        {
          stopBareString=YES;
          element=[GSWHTMLComment elementWithString:[_currentAST text]];
          _currentAST=[_currentAST nextSibling];
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
          NSDebugMLLog(@"low",@"inHTMLBareString: adding [%@]",[_currentAST text]);
          if ([_currentAST tokenType]==GSWHTMLTokenType_OPENTAG)
            [htmlBareString appendFormat:@"<%@>",[_currentAST text]];
          else if ([_currentAST tokenType]==GSWHTMLTokenType_CLOSETAG)
            [htmlBareString appendFormat:@"</%@>",[_currentAST text]];
          else
            [htmlBareString appendString:[_currentAST text]];
          NSDebugMLLog(@"low",@"htmlBareString: ==> [%@]",htmlBareString);
          _currentAST=[_currentAST nextSibling];
        };
      if (inHTMLBareString && (stopBareString || !_currentAST))
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
          [_elements addObject:element];
          element=nil;
        };
      NSDebugMLLog(@"low",@"element:%@",element);
      NSDebugMLLog(@"low",@"inHTMLBareString:%d",(int)inHTMLBareString);
      NSDebugMLLog(@"low",@"htmlBareString:%@",htmlBareString);
    };
  *_AST=_currentAST;
  NSDebugMLLog(@"low",@"_elements]:%@",_elements);
  LOGClassFnStop();
  return _elements;
};

@end

