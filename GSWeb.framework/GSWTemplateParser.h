/* GSWTemplateParser.h - GSWeb: Class GSWTemplateParser
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

// $Id$

#ifndef _GSWTemplateParser_h__
	#define _GSWTemplateParser_h__

//====================================================================
@interface GSWTemplateParser : NSObject
{
  NSString*		_templateName;
  NSString*		_frameworkName;
  NSString*		_string;
  NSStringEncoding _stringEncoding;
  NSString*	   _stringPath;
  NSString*	   _definitionsString;
  NSArray*	   _languages;
  NSString*	   _definitionsPath;
  GSWElement*   _template;
  NSDictionary* _definitions;
}

+(GSWElement*)templateNamed:(NSString*)name_
           inFrameworkNamed:(NSString*)frameworkName_
        withParserClassName:(NSString*)parserClassName
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)languages_
             definitionPath:(NSString*)definitionPath_;
+(GSWElement*)templateNamed:(NSString*)name_
           inFrameworkNamed:(NSString*)frameworkName_
            withParserClass:(Class)parserClass
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)languages_
             definitionPath:(NSString*)definitionPath_;
+(void)setDefaultParserClassName:(NSString*)parserClassName;
+(NSString*)defaultParserClassName;
+(Class)defaultParserClass;
-(id)initWithTemplateName:(NSString*)name_
          inFrameworkName:(NSString*)frameworkName_
               withString:(NSString*)HTMLString
                 encoding:(NSStringEncoding)encoding_
                 fromPath:(NSString*)HTMLPath
    withDefinitionsString:(NSString*)pageDefString
                 fromPath:(NSString*)definitionPath_
             forLanguages:(NSArray*)languages_;
-(void)dealloc;
-(NSString*)logPrefix;
-(GSWElement*)template;
-(NSArray*)templateElements;
-(NSDictionary*)definitions;

-(NSDictionary*)parseDefinitionsString:(NSString*)localDefinitionstring_
                                 named:(NSString*)localDefinitionName_
                      inFrameworkNamed:(NSString*)localFrameworkName_
                              fromPath:(NSString*)localDefinitionPath_;

-(NSDictionary*)parseDefinitionInclude:(NSString*)includeName_
                    fromFrameworkNamed:(NSString*)fromFrameworkName_
                        definitionPath:(NSString*)localDefinitionPath_;

-(NSDictionary*)processIncludes:(NSArray*)definitionsIncludes_
                          named:(NSString*)localDefinitionsName_
               inFrameworkNamed:(NSString*)localFrameworkName_
                 definitionPath:(NSString*)localDefinitionPath_;

@end

#endif //_GSWTemplateParser_h__

