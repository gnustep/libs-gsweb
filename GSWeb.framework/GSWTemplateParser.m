/* GSWTemplateParser.m - GSWeb: Class GSWTemplateParser
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
@implementation GSWTemplateParser

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)name_
		   inFrameworkNamed:(NSString*)frameworkName_
			 withHTMLString:(NSString*)HTMLString
				   htmlPath:(NSString*)HTMLPath
		  declarationString:(NSString*)pageDefString
				  languages:(NSArray*)languages_
			declarationPath:(NSString*)declarationPath_
{
  GSWElement* _template=nil;
  NSAutoreleasePool* arp = nil;
  NSMutableDictionary* pageDefElements=nil;
  BOOL pageDefParseOK=NO;
  LOGClassFnStart();
  arp=[NSAutoreleasePool new];
  NSDebugMLLog(@"low",@"template named:%@ frameworkName:%@ pageDefString=%@",name_,frameworkName_,pageDefString);
  
  //TODO remove
/*
  [ANTLRCharBuffer setTraceFlag_LA:YES];
  [ANTLRCharScanner setTraceFlag_LA:YES];
  [ANTLRLLkParser setTraceFlag_LA:YES];
  [ANTLRTokenBuffer setTraceFlag_LA:YES];
*/
  if (pageDefString && [pageDefString length]>0)
	{
	  pageDefElements=[NSMutableDictionary dictionary];
	  pageDefParseOK=[self parseDeclarationString:pageDefString
						   languages:languages_
						   named:name_
						   inFrameworkNamed:frameworkName_
						   declarationPath:declarationPath_
						   into:pageDefElements];
	}
  else
	pageDefParseOK=YES;
  NSDebugMLLog(@"low",@"template named:%@ pageDefElements=%@",name_,pageDefElements);
  if (pageDefParseOK)
	{
	  id<NSObject,ANTLRAST> htmlAST=nil;
	  NSMutableArray* _classes=[NSMutableArray array];
	  BOOL createClassesOk=NO;
	  NSEnumerator* _enum = [pageDefElements objectEnumerator];
	  id _obj=nil;
	  NSString* _className=nil;
	  NSDebugMLLog(@"low",@"template named:%@ pageDefElements=%@",name_,pageDefElements);
	  while ((_obj = [_enum nextObject]))
		{
		  _className=[_obj className];
		  if (_className)
			[_classes addObject:_className];
		};
	  createClassesOk=YES;/*[GSWApplication createUnknownComponentClasses:_classes
									  superClassName:@"GSWComponent"];*/
	  if (createClassesOk)
		{
		  NSAutoreleasePool* arpParse=nil;
		  ANTLRTextInputStreamString* htmlStream=[[ANTLRTextInputStreamString newWithString:HTMLString]
												   autorelease];
		  GSWHTMLLexer* htmlLexer=[[[GSWHTMLLexer alloc]initWithTextStream:htmlStream]
									autorelease];
		  ANTLRTokenBuffer* htmlTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:htmlLexer];
		  GSWHTMLParser* htmlParser=[[[GSWHTMLParser alloc] initWithTokenBuffer:htmlTokenBuffer]
									  autorelease];
		  NSDebugMLLog(@"low",@"template named:%@ HTMLString=%@",name_,HTMLString);
		  arpParse=[NSAutoreleasePool new];
		  NS_DURING
			{
			  [htmlParser document];
			  if ([htmlParser isError])
				{
				  LOGError(@"Parser Errors : %@",[htmlParser errors]);
				  ExceptionRaise(@"GSWTemplateParser",
								 @"GSWTemlateParser: Errors in HTML parsing template named %@: %@\nAST:\n%@",
								 name_,
								 [htmlParser errors],
								 [htmlParser AST]);
				};
			  htmlAST=[htmlParser AST];
			  NSDebugMLLog0(@"low",@"HTML Parse OK!");
			}
		  NS_HANDLER
			{
			  LOGError(@"template named:%@ HTML Parse failed!",name_);
			  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,@"In [htmlParser document]... template named:%@ HTML Parse failed!",name_);
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
		  [htmlAST autorelease];
		  NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");
		};
	  if (htmlAST)
		{
		  /*		  ANTLRTextInputStreamString* elementStream=[[ANTLRTextInputStreamString new]autorelease];
					  GSWHTMLAttrLexer* htmlAttrLexer=[[[GSWHTMLAttrLexer alloc]initWithTextStream:elementStream]autorelease];
					  ANTLRTokenBuffer* htmlAttrTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:htmlAttrLexer];
					  GSWHTMLAttrParser* htmlAttrParser=[[[GSWHTMLAttrParser alloc] initWithTokenBuffer:htmlAttrTokenBuffer]autorelease];*/
		  NSMutableDictionary* tagsNames=[NSMutableDictionary dictionary];
		  NSMutableDictionary* tagsAttrs=[NSMutableDictionary dictionary];
		  NSDebugMLLog(@"low",@"pageDefElements=%@",pageDefElements);
		  NS_DURING
			{
			  _template=[self createElementsStartingWithAST:&htmlAST
							  stopOnTagNamed:nil
							  withDefinitions:pageDefElements
							  withLanguages:languages_
							  /*						  withTagStream:elementStream
														  withTagParser:htmlAttrParser*/
							  withTagsNames:tagsNames
							  withTagsAttr:tagsAttrs
							  templateNamed:name_];
			  NSDebugMLLog(@"low",@"template named:%@ _template=%@",name_,_template);
			}
		  NS_HANDLER
			{
			  LOGSeriousError(@"template named:%@ createElements failed!",name_);
			  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In createElementsStartingWithAST...");
			  [localException raise];
			}
		  NS_ENDHANDLER;
		};
	}
  else
	{
	  LOGError(@"Template named:%@ componentDefinition parse failed :%@",
			   name_,
			   pageDefString);
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
  [_template retain];
  NSDebugMLLog0(@"low",@"DESTROY(arp)\n");
  DESTROY(arp);
  NSDebugMLLog0(@"low",@"DESTROYED(arp)\n");
  [_template autorelease];
  NSDebugMLLog0(@"low",@"Display Template\n");
  NSDebugMLLog(@"low",@"template named:%@ _template=%@",name_,_template);
  LOGClassFnStop();
  return _template;
};

//--------------------------------------------------------------------
+(BOOL)parseTag:(ANTLRDefAST)_AST
/*  withTagStream:(ANTLRTextInputStreamString*)_tagStream
  withTagParser:(GSWHTMLAttrParser*)_tagParser*/
  withTagsNames:(NSMutableDictionary*)tagsNames
  withTagsAttrs:(NSMutableDictionary*)tagsAttrs
{
  BOOL htmlAttrParseOK=YES;
  NSString* tagName=[tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  if (!tagName && ([_AST tokenType]==GSWHTMLTokenType_OPENTAG || [_AST tokenType]==GSWHTMLTokenType_CLOSETAG))
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
	  //[_tagStream setString:[_AST text]];
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
		  NSDebugMLLog(@"low",@"tagName=%@ tagAttrs=%@",tagName,tagAttrs);
		  htmlAttrParseOK=YES;
		}
	  NS_HANDLER
		{
		  htmlAttrParseOK=NO;
		  LOGError(@"PARSE PB:[%@]",[_AST text]);//TODO
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In [_tagParser tag]...");
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
		  NSDebugMLLog(@"low",@"Add tagName:[%@]",tagName);
		  [tagsNames setObject:tagName
					 forKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
		  NSDebugMLLog(@"low",@"Verify tagName=%@",[tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]); //TODO bad hack
		  NSDebugMLLog(@"low",@"Add tagsAttrs:[%@]",tagAttrs);
		  if (tagAttrs)
			{
			  [tagsAttrs setObject:tagAttrs
						 forKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
			  NSDebugMLLog(@"low",@"Verify tagAttrs=%@",[tagsAttrs objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]); //TODO bad hack
			};
		};
	};
  LOGClassFnStop();
  return htmlAttrParseOK;
};

//--------------------------------------------------------------------
+(NSString*)getTagNameFor:(ANTLRDefAST)_AST
/*			withTagStream:(ANTLRTextInputStreamString*)_tagStream
			withTagParser:(GSWHTMLAttrParser*)_tagParser*/
			withTagsNames:(NSMutableDictionary*)tagsNames
			withTagsAttrs:(NSMutableDictionary*)tagsAttrs
{
  NSString* tagName=[tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[_AST text]);
  if (!tagName)
	{
	  BOOL htmlAttrParseOK=[self parseTag:_AST
								 /*withTagStream:_tagStream
								 withTagParser:_tagParser*/
								 withTagsNames:tagsNames
								 withTagsAttrs:tagsAttrs];
	  if (htmlAttrParseOK)
		tagName=[tagsNames objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
	};
  NSDebugMLLog(@"low",@"tagName:[%@]",tagName);
  LOGClassFnStop();
  return tagName;
};

//--------------------------------------------------------------------
+(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)_AST
/*				 withTagStream:(ANTLRTextInputStreamString*)_tagStream
				 withTagParser:(GSWHTMLAttrParser*)_tagParser*/
				 withTagsNames:(NSMutableDictionary*)tagsNames
				 withTagsAttrs:(NSMutableDictionary*)tagsAttrs
{
  NSDictionary* tagAttrs=[tagsAttrs objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"[%@]",[_AST text]);
  if (!tagAttrs)
	{
	  BOOL htmlAttrParseOK=[self parseTag:_AST
/*								 withTagStream:_tagStream
								 withTagParser:_tagParser*/
								 withTagsNames:tagsNames
								 withTagsAttrs:tagsAttrs];
	  if (htmlAttrParseOK)
		tagAttrs=[tagsAttrs objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)_AST]]; //TODO bad hack
	};
  NSDebugMLLog(@"low",@"tagAttrs:[%@]",tagAttrs);
  LOGClassFnStop();
  return tagAttrs;
};

//--------------------------------------------------------------------
+(GSWElement*)createElementsStartingWithAST:(ANTLRDefAST*)_AST
							stopOnTagNamed:(NSString*)_stopTagName
						   withDefinitions:(NSDictionary*)pageDefElements
							 withLanguages:(NSArray*)languages_
/*							 withTagStream:(ANTLRTextInputStreamString*)_tagStream
							 withTagParser:(GSWHTMLAttrParser*)_tagParser*/
							 withTagsNames:(NSMutableDictionary*)tagsNames
							  withTagsAttr:(NSMutableDictionary*)tagsAttrs
							  templateNamed:(NSString*)templateName_
{
  GSWElement* result=nil;
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
	  BOOL htmlAttrParseOK=NO;	  
	  BOOL stopBareString=NO;
	  NSDebugMLLog(@"low",@"[_currentAST: text=[%@] Type=%d",[_currentAST text],[_currentAST tokenType]);
	  NSDebugMLLog(@"low",@"end=%s inHTMLBareString=%s stopBareString=%s",
			end ? "YES" : "NO",
			inHTMLBareString ? "YES" : "NO",
			stopBareString ? "YES" : "NO");
	  if ([_currentAST tokenType]==GSWHTMLTokenType_OPENTAG || [_currentAST tokenType]==GSWHTMLTokenType_CLOSETAG)
		{
		  tagName=[self getTagNameFor:_currentAST
/*						withTagStream:_tagStream
						withTagParser:_tagParser*/
						withTagsNames:tagsNames
						withTagsAttrs:tagsAttrs];
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
				  tagAttrs=[self getTagAttrsFor:_currentAST
								 /*						withTagStream:_tagStream
														withTagParser:_tagParser*/
								 withTagsNames:tagsNames
								 withTagsAttrs:tagsAttrs];
				  NSDebugMLLog(@"low",@"tagAttrs=%@",tagAttrs);
				  if ([tagName caseInsensitiveCompare:@"gsweb"]==NSOrderedSame
					  || [tagName caseInsensitiveCompare:@"webobject"]==NSOrderedSame)
					{
					  NSDebugMLLog0(@"low",@"Found GSWeb Tag");
					  NSDebugMLLog(@"low",@"tagAttrs=%@",tagAttrs);
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
						  NSDebugMLLog(@"low",@"GSWeb Tag: name:[%@]",name);
						  if (!name)
							{
							  LOGError(@"No name for Element:%@",[_currentAST text]);//TODO
							  ExceptionRaise(@"GSWTemplateParser",@"GSWTemlateParser: no name for GNUstepWeb tag in template named %@",
											 templateName_);
							}
						  else
							{
							  GSWPageDefElement* pageDefElement=[pageDefElements objectForKey:name];
							  NSDebugMLLog(@"low",@"pageDefElement:[%@]",
										   pageDefElement);
							  NSDebugMLLog(@"low",@"GSWeb Tag pageDefElement:[%@]",
										   pageDefElement);
							  if (pageDefElement)
								{
								  NSDictionary* _associations=[pageDefElement associations];
								  NSString* className=nil;
								  className=[pageDefElement className];
								  NSDebugMLLog(@"low",@"GSWeb Tag className:[%@]",className);
								  if (className)
									{
									  GSWElement* children=nil;
									  children=[self createElementsStartingWithAST:&nextAST
													 stopOnTagNamed:tagName
													 withDefinitions:pageDefElements
													 withLanguages:languages_
													 /*withTagStream:_tagStream
													   withTagParser:_tagParser*/
													 withTagsNames:tagsNames
													 withTagsAttr:tagsAttrs
													 templateNamed:templateName_];
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
											if (![_tagAttrKey isEqualToString:@"name"] && ![_associations objectForKey:_tagAttrKey])
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
													  template:children
													  languages:languages_];
									  if (!element)
										{
										  ExceptionRaise(@"GSWTemplateParser",
														 @"GSWTemplateParser: Creation failed for element named:%@ className:%@ in template named %@",
														 [pageDefElement elementName],
														 className,
														 templateName_);
										};
									}
								  else
									{
									  ExceptionRaise(@"GSWTemplateParser",
													 @"GSWTemplateParser: No class name in page definition for tag named:%@ pageDefElement=%@ in template named %@",
													 name,
													 pageDefElement,
													 templateName_);
									};
								}
							  else
								{
								  ExceptionRaise(@"GSWTemplateParser",
												 @"No element definition for tag named:%@ in template named %@",
												 name,
												 templateName_);
								};
							};
						  _currentAST=nextAST;
						};
					};
				}
			  else
				{				  
				  if (_stopTagName && [tagName caseInsensitiveCompare:_stopTagName]==NSOrderedSame)
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
/*	  else if ([_currentAST tokenType]==GSWHTMLTokenType_INCLUDE)
		{
		  stopBareString=YES;
		  element=[GSWHTMLComment elementWithString:[_currentAST text]];
		  _currentAST=[_currentAST nextSibling];
		};*/
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
  result=[[[GSWHTMLStaticGroup alloc]initWithContentElements:_elements]autorelease];
  NSDebugMLLog(@"low",@"result:%@",result);
  LOGClassFnStop();
  return result;
};

//--------------------------------------------------------------------
+(BOOL)parseDeclarationInclude:(NSString*)includeName_
			fromFrameworkNamed:(NSString*)fromFrameworkName_
			   declarationPath:(NSString*)declarationPath_
					 languages:(NSArray*)languages_
						  into:(NSMutableDictionary*)pageDefElements_
{
  BOOL pageDefParseOK=NO;
  NSString* _frameworkName=nil;
  NSString* _pageDefName=nil;
  NSString* _language=nil;
  NSString* _resourceName=nil;
  NSString* _pageDefResourceName=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _path=nil;
  int iLanguage=0;
  LOGObjectFnStart();  
  NSDebugMLLog(@"gswcomponents",@"includeName_=%@",includeName_);
  _resourceManager=[GSWApp resourceManager];
  _pageDefName=[includeName_ lastPathComponent];
  _frameworkName=[includeName_ stringByDeletingLastPathComponent];
  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
  NSDebugMLLog(@"gswcomponents",@"fromFrameworkName_=%@",fromFrameworkName_);
  if ([_frameworkName length]==0)
	_frameworkName=fromFrameworkName_;
  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);

  _resourceName=[_pageDefName stringByAppendingString:GSWPagePSuffix];
  _pageDefResourceName=[_pageDefName stringByAppendingString:GSWComponentDefinitionPSuffix];
  NSDebugMLLog(@"gswcomponents",@"_resourceName=%@",_resourceName);


  for(iLanguage=0;iLanguage<=[languages_ count] && !_path;iLanguage++)
	{
	  if (iLanguage<[languages_ count])
		_language=[languages_ objectAtIndex:iLanguage];
	  else
		_language=nil;
	  _path=[_resourceManager pathForResourceNamed:_resourceName
							  inFramework:_frameworkName
							  language:_language];
	  NSDebugMLLog(@"gswcomponents",@"Search In Page Component: _language=%@ _path=%@ declarationPath=%@",
				   _language,
				   _path,
				   declarationPath_);
	  if (_path)
		_path=[_path stringByAppendingPathComponent:_pageDefResourceName];
	  else
		{
		  _path=[_resourceManager pathForResourceNamed:_pageDefResourceName
								  inFramework:_frameworkName
								  language:_language];
		  NSDebugMLLog(@"gswcomponents",@"Search in Component Definition _language=%@ _path=%@ (declarationPath=%@)",
					   _language,
					   _path,
					   declarationPath_);
		};
	  if ([_path isEqualToString:declarationPath_])
		{
		  _path=nil;
		  iLanguage=[languages_ count]-1;
		};
	};
  if (_path)
	{
	  NSString* _pageDefString=nil;
	  NSDebugMLLog(@"low",@"_path=%@",_path);
	  //NSString* pageDefPath=[path stringByAppendingString:_definitionPath];
	  //TODO use encoding !
	  _pageDefString=[NSString stringWithContentsOfFile:_path];
	  if (_pageDefString)
		{
		  pageDefParseOK=[self parseDeclarationString:_pageDefString
							   languages:languages_
							   named:includeName_
							   inFrameworkNamed:_frameworkName
							   declarationPath:_path
							   into:pageDefElements_];
		  if (!pageDefParseOK)
			LOGError(@"Template componentDefinition parse failed for included file:%@ in framework:%@ (declarationPath=%@)",
					 includeName_,
					 _frameworkName,
					 declarationPath_);
		}
	  else
		{
		  ExceptionRaise(@"GSWTemplateParser",
						 @"Can't load included component definition named:%@ in framework:%@ (declarationPath=%@)",
						 includeName_,
						 _frameworkName,
						 declarationPath_);
		};
	}
  else
	{
	  ExceptionRaise(@"GSWTemplateParser",
					 @"Can't find included component definition named:%@ in framework:%@ (declarationPath=%@)",
					 includeName_,
					 _frameworkName,
					 declarationPath_);
	};
  return pageDefParseOK;
};

//--------------------------------------------------------------------
+(BOOL)parseDeclarationString:(NSString*)pageDefString
					languages:(NSArray*)languages_
						named:(NSString*)name_
			 inFrameworkNamed:(NSString*)frameworkName_
			  declarationPath:(NSString*)declarationPath_
						 into:(NSMutableDictionary*)pageDefElements_
{
  BOOL pageDefParseOK=NO;
  NSArray* pageDefIncludes=nil;
  NSMutableDictionary* _pageDefElements=nil;
  LOGClassFnStart();
  {
	NSAutoreleasePool* arpParse=nil;
	ANTLRTextInputStreamString* pageDefStream=nil;
	GSWPageDefLexer* pageDefLexer=nil;
	ANTLRTokenBuffer* pageDefTokenBuffer=nil;
	GSWPageDefParser* pageDefParser=nil;

	arpParse=[NSAutoreleasePool new];
	pageDefStream=[[ANTLRTextInputStreamString newWithString:pageDefString]
					autorelease];
	pageDefLexer=[[[GSWPageDefLexer alloc]initWithTextStream:pageDefStream]
				   autorelease];
	pageDefTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:pageDefLexer];
	pageDefParser=[[[GSWPageDefParser alloc] initWithTokenBuffer:pageDefTokenBuffer]
					autorelease];
	NSDebugMLLog(@"low",@"name:%@ pageDefString=%@",name_,pageDefString);
	NS_DURING
	  {
		NSDebugMLLog0(@"low",@"Call pageDefParser");
		[pageDefParser document];
		if ([pageDefParser isError])
		  {
			LOGError(@"Parser Errors : %@",[pageDefParser errors]);
			ExceptionRaise(@"GSWTemplateParser",
						   @"GSWTemlateParser: Errors in PageDef parsing template named %@: %@\nString:\n%@",
						   name_,
						   [pageDefParser errors],
						   pageDefString);
		  };
		NSDebugMLLog0(@"low",@"Call [pageDefParser elements]");
		_pageDefElements=[[[pageDefParser elements] mutableCopy] autorelease];
		pageDefIncludes=[pageDefParser includes];
		pageDefParseOK=YES;
		NSDebugMLLog0(@"low",@"PageDef Parse OK!");
		NSDebugMLLog(@"low",@"_pageDefElements=%@",_pageDefElements);
	  }
	NS_HANDLER
	  {
		LOGError(@"name:%@ PageDef Parse failed!",name_);
		localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In [pageDefParser document]...");
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
		NSDebugMLLog(@"low",
					 @"thread current_pool=%@",
					 [NSThread currentThread]->_autorelease_vars.current_pool);
		NSDebugMLLog(@"low",
					 @"thread current_pool _parentAutoreleasePool=%@",
					 [[NSThread currentThread]->_autorelease_vars.current_pool _parentAutoreleasePool]);
	  };
#endif
	if (pageDefParseOK)
	  {
		[_pageDefElements retain];
		[pageDefIncludes retain];
	  };
	NSDebugMLLog0(@"low",@"DESTROY(arpParse)\n");
	DESTROY(arpParse);
	NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");
	if (pageDefParseOK)
	  {
		[_pageDefElements autorelease];
		[pageDefIncludes autorelease];
	  }
	else
	  {
		_pageDefElements=nil;
		pageDefIncludes=nil;
	  };
  };
  if (pageDefParseOK)
	{
	  [pageDefElements_ addDefaultEntriesFromDictionary:_pageDefElements];
	  pageDefParseOK=[self processIncludes:pageDefIncludes
						   languages:languages_
						   named:name_
						   inFrameworkNamed:frameworkName_
						   declarationPath:declarationPath_
						   into:pageDefElements_];
	  if (!pageDefParseOK)
		LOGError(@"Template name:%@ componentDefinition parse failed for pageDefIncludes:%@",
				 name_,
				 pageDefIncludes);
	};
  return pageDefParseOK;
};

//--------------------------------------------------------------------
+(BOOL)processIncludes:(NSArray*)pageDefIncludes_
			 languages:(NSArray*)languages_
				 named:(NSString*)name_
	  inFrameworkNamed:(NSString*)frameworkName_
	   declarationPath:(NSString*)declarationPath_
				  into:(NSMutableDictionary*)pageDefElements_
{
  BOOL pageDefParseOK=YES;
  int _count=0;
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"name:%@ frameworkName_=%@",name_,frameworkName_);
  _count=[pageDefIncludes_ count];
  if (pageDefIncludes_ && _count>0)
	{
	  int i=0;
	  NSString* _includeName=nil;
	  for(i=0;pageDefParseOK && i<_count;i++)
		{
		  _includeName=[pageDefIncludes_ objectAtIndex:i];
		  pageDefParseOK=[self parseDeclarationInclude:_includeName
							   fromFrameworkNamed:frameworkName_
							   declarationPath:declarationPath_
							   languages:languages_
							   into:pageDefElements_];
		  if (!pageDefParseOK)
			LOGError(@"Template componentDefinition parse failed for _includeName:%@",
					 _includeName);
		};
	};
  LOGClassFnStop();
  return pageDefParseOK;
};
@end

