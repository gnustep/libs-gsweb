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

#include <GSWeb/GSWeb.h>
#include <gsantlr/ANTLRCommon.h>
#include <gsantlr/ANTLRTextStreams.h>
#include "GSWPageDefLexer.h"
#include "GSWPageDefParser.h"
#include "GSWPageDefParserExt.h"

Class GSWTemplateParser_DefaultParserClass=Nil;
//====================================================================
@implementation GSWTemplateParser

+(void)initialize
{
  if (self == [GSWTemplateParser class])
    {
      GSWTemplateParser_DefaultParserClass=NSClassFromString(GSWEB_DEFAULT_HTML_PARSER_CLASS_NAME);
      NSAssert(GSWTemplateParser_DefaultParserClass,@"Bad GSWEB_DEFAULT_HTML_PARSER_CLASS_NAME");
    };
};

//--------------------------------------------------------------------
+(void)setDefaultParserClassName:(NSString*)parserClassName
{
  NSAssert(parserClassName,@"No defaultParser Class Name");
  GSWTemplateParser_DefaultParserClass=NSClassFromString(parserClassName);
  NSAssert1(GSWTemplateParser_DefaultParserClass,@"No class named %@",parserClassName);
};

//--------------------------------------------------------------------
+(Class)defaultParserClass
{
  return GSWTemplateParser_DefaultParserClass;
};

//--------------------------------------------------------------------
+(NSString*)defaultParserClassName
{
  return [NSString stringWithCString:[GSWTemplateParser_DefaultParserClass name]];
};

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)name_
           inFrameworkNamed:(NSString*)frameworkName_
        withParserClassName:(NSString*)parserClassName
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding_
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)languages_
             definitionPath:(NSString*)definitionPath_
{
  GSWElement* resultTemplate=nil;
  Class parserClass=Nil;
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"definitionPath_=%@",definitionPath_);
  if (parserClassName)
    {
      parserClass=NSClassFromString(parserClassName);
      NSAssert1(parserClass,@"No Parser class named %@",parserClassName);
    };
  resultTemplate=[self templateNamed:name_
                       inFrameworkNamed:frameworkName_
                       withParserClass:parserClass
                       withString:HTMLString
                       encoding:encoding_
                       fromPath:HTMLPath
                       definitionsString:pageDefString
                       languages:languages_
                       definitionPath:definitionPath_];
  LOGClassFnStop();
  return resultTemplate;
};

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)name_
           inFrameworkNamed:(NSString*)frameworkName_
            withParserClass:(Class)parserClass
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding_
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)languages_
             definitionPath:(NSString*)definitionPath_
{
  GSWElement* resultTemplate=nil;
  GSWTemplateParser* templateParser=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"low",@"template named:%@ frameworkName:%@ pageDefString=%@",name_,frameworkName_,pageDefString);
  NSDebugMLLog(@"low",@"definitionPath_=%@",definitionPath_);
  if (!parserClass)
    {
      parserClass=[self defaultParserClass];
      NSAssert(parserClass,@"No defaultParser Class");
    };
  templateParser=[[[parserClass alloc] initWithTemplateName:name_
                                       inFrameworkName:frameworkName_
                                       withString:HTMLString
                                       encoding:encoding_
                                       fromPath:HTMLPath
                                       withDefinitionsString:pageDefString
                                       fromPath:definitionPath_
                                       forLanguages:languages_] autorelease];
  if (templateParser)
    resultTemplate=[templateParser template];
  LOGClassFnStop();
  return resultTemplate;
};

//--------------------------------------------------------------------
-(id)initWithTemplateName:(NSString*)name_
          inFrameworkName:(NSString*)frameworkName_
               withString:(NSString*)HTMLString
                 encoding:(NSStringEncoding)encoding_
                 fromPath:(NSString*)HTMLPath
    withDefinitionsString:(NSString*)pageDefString
                 fromPath:(NSString*)definitionPath_
             forLanguages:(NSArray*)languages_
{
  if ((self=[self init]))
    {
      ASSIGN(_templateName,name_);
      ASSIGN(_frameworkName,frameworkName_);
      ASSIGN(_string,HTMLString);
      _stringEncoding=encoding_;
      ASSIGN(_stringPath,HTMLPath);
      ASSIGN(_definitionsString,pageDefString);
      ASSIGN(_languages,languages_);
      ASSIGN(_definitionFilePath,definitionPath_);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_templateName);
  DESTROY(_frameworkName);
  DESTROY(_string);
  DESTROY(_stringPath);
  DESTROY(_definitionsString);
  DESTROY(_languages);
  DESTROY(_definitionFilePath);
  DESTROY(_template);
  DESTROY(_definitions);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)logPrefix
{
  return [NSString stringWithFormat:@"Template Parser for template named %@ in framework %@ at %@ - ",
                   _templateName,
                   _frameworkName,
                   _stringPath];
};

//--------------------------------------------------------------------
-(GSWElement*)template
{
  LOGObjectFnStart();
  if (!_template)
    {
      NSArray* elements=nil;
      NSDictionary* definitions=nil;
      definitions=[self definitions];
      if (!definitions)
        {
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Can't get definitions",
                         [self logPrefix]);
        }
      else
        {
          /*
            NSMutableArray* _classes=[NSMutableArray array];
            BOOL createClassesOk=NO;
            NSEnumerator* _enum = [definitionsElements objectEnumerator];
            id _obj=nil;
            NSString* _className=nil;
            NSDebugMLLog(@"low",@"template named:%@ definitionsElements=%@",name_,definitionsElements);
            while ((_obj = [_enum nextObject]))
            {
            _className=[_obj className];
            if (_className)
            [_classes addObject:_className];
            };
            createClassesOk=YES;/[GSWApplication createUnknownComponentClasses:_classes superClassName:@"GSWComponent"];
            if (createClassesOk)
            {
          */  
          NS_DURING
            {
              elements=[self templateElements];
            }
          NS_HANDLER
            {
              LOGError(@"%@ Parse failed! Exception:%@",
                       [self logPrefix],
                       localException);
              localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                      @"%@ - In [htmlParser document] Parse failed!",
                                                                      [self logPrefix]);
              [localException retain];
              [localException autorelease];
              [localException raise];
            }
          NS_ENDHANDLER;
          if (elements)
            {
              _template=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements];
            };
        };
    };
  LOGObjectFnStop();
  return _template;
};

//--------------------------------------------------------------------
-(NSArray*)templateElements
{
  [self subclassResponsibility: _cmd];
  return nil;
};

//--------------------------------------------------------------------
-(NSDictionary*)definitions
{
  LOGObjectFnStart();
  if (!_definitions)
    {
      NSDebugMLLog(@"low",@"_definitionFilePath=%@",_definitionFilePath);
      if ([_definitionsString length]==0)
        {
          ASSIGN(_definitions,[NSDictionary dictionary]);
        }
      else
        {
          NSMutableSet* processedFiles=[NSMutableSet setWithObject:_definitionFilePath];
          NSDictionary* tmpDefinitions=[self parseDefinitionsString:_definitionsString
                                             named:_templateName
                                             inFrameworkNamed:_frameworkName
                                             processedFiles:processedFiles];
          if (tmpDefinitions)
            ASSIGN(_definitions,[NSDictionary dictionaryWithDictionary:tmpDefinitions]);
        };
    };
  LOGObjectFnStop();
  return _definitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)parseDefinitionsString:(NSString*)localDefinitionstring_
                                 named:(NSString*)localDefinitionName_
                      inFrameworkNamed:(NSString*)localFrameworkName_
                        processedFiles:(NSMutableSet*)processedFiles
{
  NSDictionary* returnedLocalDefinitions=nil;
  NSMutableDictionary* localDefinitions=nil;
  NSDictionary* tmpDefinitions=nil;
  NSArray* definitionsIncludes=nil;
  NSAutoreleasePool* arpParse=nil;
  ANTLRTextInputStreamString* definitionsStream=nil;
  GSWPageDefLexer* definitionsLexer=nil;
  ANTLRTokenBuffer* definitionsTokenBuffer=nil;
  GSWPageDefParser* definitionsParser=nil;
  LOGObjectFnStart();
  arpParse=[NSAutoreleasePool new];
  definitionsStream=[[ANTLRTextInputStreamString newWithString:localDefinitionstring_]
                      autorelease];
  definitionsLexer=[[[GSWPageDefLexer alloc]initWithTextStream:definitionsStream]
                     autorelease];
  definitionsTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:definitionsLexer];
  definitionsParser=[[[GSWPageDefParser alloc] initWithTokenBuffer:definitionsTokenBuffer]
                      autorelease];
  NSDebugMLLog(@"low",@"processedFiles=%@",processedFiles);
  NSDebugMLLog(@"low",@"name:%@ definitionsString=%@",
               localDefinitionName_,
               localDefinitionstring_);
  NS_DURING
    {
      NSDebugMLLog0(@"low",@"Call definitionsParser");
      [definitionsParser document];
      if ([definitionsParser isError])
        {
          LOGError(@"%@ %@",
                   [self logPrefix],
                   [definitionsParser errors]);
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Errors in Definitions parsing template named %@: %@\nString:\n%@",
                         [self logPrefix],
                         localDefinitionName_,
                         [definitionsParser errors],
                         localDefinitionstring_);
        };
      NSDebugMLLog0(@"low",@"Call [definitionsParser elements]");
      tmpDefinitions=[[[definitionsParser elements] mutableCopy] autorelease];
      definitionsIncludes=[definitionsParser includes];
      NSDebugMLLog0(@"low",@"Definitions Parse OK!");
      NSDebugMLLog(@"low",@"localDefinitions=%@",tmpDefinitions);
      NSDebugMLLog(@"low",@"definitionsIncludes=%@",definitionsIncludes);
    }
  NS_HANDLER
    {
      LOGError(@"%@ name:%@ Definitions Parse failed!",
               [self logPrefix],
               localDefinitionName_);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"%@ In [definitionsParser document]...",
                                                              [self logPrefix]);
      [localException retain];
      DESTROY(arpParse);
      [localException autorelease];
      [localException raise];
    }
  NS_ENDHANDLER;
  NSDebugMLLog0(@"low",@"arpParse infos:\n");
  [tmpDefinitions retain];
  [definitionsIncludes retain];
  NSDebugMLLog0(@"low",@"DESTROY(arpParse)\n");
  DESTROY(arpParse);
  NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");
  [tmpDefinitions autorelease];
  [definitionsIncludes autorelease];
  
  if (tmpDefinitions)
    localDefinitions=[NSMutableDictionary dictionaryWithDictionary:tmpDefinitions];
  if (localDefinitions)
    {
      NSDebugMLLog(@"low",@"definitionsIncludes:%@\n",definitionsIncludes);
      NSDebugMLLog(@"low",@"localDefinitionName_:%@\n",localDefinitionName_);
      NSDebugMLLog(@"low",@"localFrameworkName_:%@\n",localFrameworkName_);
      NSDebugMLLog(@"low",@"processedFiles:%@\n",processedFiles);
      tmpDefinitions=[self processIncludes:definitionsIncludes
                           named:localDefinitionName_
                           inFrameworkNamed:localFrameworkName_
                           processedFiles:processedFiles];
      NSDebugMLLog(@"low",@"tmpDefinitions:%@\n",tmpDefinitions);
      if (tmpDefinitions)
        [localDefinitions addDefaultEntriesFromDictionary:tmpDefinitions];			  
      else
        {
          localDefinitions=nil;
          LOGError(@"%@ Template name:%@ componentDefinition parse failed for definitionsIncludes:%@",
                   [self logPrefix],
                   localDefinitionName_,
                   definitionsIncludes);
        };
      NSDebugMLLog(@"low",@"localDefinitions:%@\n",localDefinitions);
    };
  NSDebugMLLog(@"low",@"localDefinitions:%@\n",localDefinitions);
  if (localDefinitions)
    returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)parseDefinitionInclude:(NSString*)includeName_
                    fromFrameworkNamed:(NSString*)fromFrameworkName_
                        processedFiles:(NSMutableSet*)processedFiles
{
  NSDictionary* returnedLocalDefinitions=nil;
  NSMutableDictionary* localDefinitions=nil;
  NSDictionary* tmpDefinitions=nil;
  NSString* localFrameworkName=nil;
  NSString* localDefinitionName=nil;
  NSString* _language=nil;
  NSString* _resourceName=nil;
  NSString* localDefinitionResourceName=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _path=nil;
  int iLanguage=0;
  int iName=0;
  LOGObjectFnStart();  
  NSDebugMLLog(@"gswcomponents",@"includeName_=%@",includeName_);
  _resourceManager=[GSWApp resourceManager];
  localDefinitionName=[includeName_ lastPathComponent];
  localFrameworkName=[includeName_ stringByDeletingLastPathComponent];
  NSDebugMLLog(@"gswcomponents",@"localFrameworkName=%@",localFrameworkName);
  NSDebugMLLog(@"gswcomponents",@"fromFrameworkName_=%@",fromFrameworkName_);
  if ([localFrameworkName length]==0)
    localFrameworkName=fromFrameworkName_;
  NSDebugMLLog(@"gswcomponents",@"localFrameworkName=%@",localFrameworkName);

  for(iLanguage=0;iLanguage<=[_languages count] && !_path;iLanguage++)
    {
      if (iLanguage<[_languages count])
        _language=[_languages objectAtIndex:iLanguage];
      else
        _language=nil;
      for(iName=0;!_path && iName<2;iName++)
        {
          _resourceName=[localDefinitionName stringByAppendingString:GSWPagePSuffix[GSWebNamingConvForRound(iName)]];
          localDefinitionResourceName=[localDefinitionName stringByAppendingString:GSWComponentDefinitionPSuffix[GSWebNamingConvForRound(iName)]];
          NSDebugMLLog(@"gswcomponents",@"_resourceName=%@ localDefinitionResourceName=%@ localDefinitionName=%@",
                       _resourceName,
                       localDefinitionResourceName,
                       localDefinitionName);
          NSDebugMLLog(@"gswcomponents",@"Search %@ Language=%@",_resourceName,_language);
          _path=[_resourceManager pathForResourceNamed:_resourceName
                                  inFramework:localFrameworkName
                                  language:_language];
          NSDebugMLLog(@"gswcomponents",@"Search In Page Component: _language=%@ _path=%@ processedFiles=%@",
                       _language,
                       _path,
                       processedFiles);
          if (_path)
            {
              _path=[_path stringByAppendingPathComponent:localDefinitionResourceName];
              NSDebugMLLog(@"gswcomponents",@"Found %@ Language=%@ : %@",_resourceName,_language,_path);
              if ([processedFiles containsObject:_path])
                {
                  NSDebugMLLog(@"gswcomponents",@"path=%@ already processed",_path);
                  _path=nil;
                  if (_language)
                    iLanguage=[_languages count]-1;//For directly go to no language search  so we don't include (for exemple) an English file for a french file
                };
            };
          if (!_path)
            {
              NSDebugMLLog(@"gswcomponents",@"Direct Search %@ Language=%@",localDefinitionResourceName,_language);
              _path=[_resourceManager pathForResourceNamed:localDefinitionResourceName
                                      inFramework:localFrameworkName
                                      language:_language];
              if (_path)
                {
                  NSDebugMLLog(@"gswcomponents",@"Direct Found %@ Language=%@ : %@",localDefinitionResourceName,_language,_path);
                  if ([processedFiles containsObject:_path])
                    {
                      NSDebugMLLog(@"gswcomponents",@"path=%@ already processed",_path);
                      _path=nil;
                      if (_language)
                        iLanguage=[_languages count]-1;//For directly go to no language search  so we don't include (for exemple) an English file for a french file
                    };
                };
              NSDebugMLLog(@"gswcomponents",@"Direct Search in Component Definition _language=%@ _path=%@ (processedFiles=%@)",
                           _language,
                           _path,
                           processedFiles);
            };          
          NSDebugMLLog(@"gswcomponents",@"Search In Page Component: _language=%@ _path=%@ processedFiles=%@",
                       _language,
                       _path,
                       processedFiles);
        };
    };
  if (_path)
    {
      NSString* _pageDefString=nil;
      NSDebugMLLog(@"low",@"_path=%@",_path);
      [processedFiles addObject:_path];
      //NSString* pageDefPath=[path stringByAppendingString:_definitionPath];
      //TODO use encoding !
      _pageDefString=[NSString stringWithContentsOfFile:_path];
      NSDebugMLLog(@"low",@"path=%@: _pageDefString:%@\n",_path,_pageDefString);
      if (_pageDefString)
        {
          tmpDefinitions=[self parseDefinitionsString:_pageDefString
                               named:includeName_
                               inFrameworkNamed:localFrameworkName
                               processedFiles:processedFiles];
          NSDebugMLLog(@"low",@"tmpDefinitions:%@\n",tmpDefinitions);
          if (tmpDefinitions)
            localDefinitions=[NSMutableDictionary dictionaryWithDictionary:tmpDefinitions];
          else
            {
              LOGError(@"%@ Template componentDefinition parse failed for included file:%@ in framework:%@ (processedFiles=%@)",
                       [self logPrefix],
                       includeName_,
                       localFrameworkName,
                       processedFiles);
            };
          NSDebugMLLog(@"low",@"localDefinitions:%@\n",localDefinitions);
        }
      else
        {
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Can't load included component definition named:%@ in framework:%@ (processedFiles=%@)",
                         [self logPrefix],
                         includeName_,
                         localFrameworkName,
                         processedFiles);
        };
    }
  else
    {
      ExceptionRaise(@"GSWTemplateParser",
                     @"%@ Can't find included component definition named:%@ in framework:%@ (processedFiles=%@)",
                     [self logPrefix],
                     includeName_,
                     localFrameworkName,
                     processedFiles);
    };
  NSDebugMLLog(@"low",@"localDefinitions:%@\n",localDefinitions);
  if (localDefinitions)
    returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)processIncludes:(NSArray*)definitionsIncludes_
                          named:(NSString*)localDefinitionsName_
               inFrameworkNamed:(NSString*)localFrameworkName_
                 processedFiles:(NSMutableSet*)processedFiles
{
  int _count=0;
  NSDictionary* returnedLocalDefinitions=nil;
  NSMutableDictionary* localDefinitions=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"name:%@ frameworkName_=%@ definitionsIncludes_=%@",
               localDefinitionsName_,
               localFrameworkName_,
               definitionsIncludes_);
  localDefinitions=[NSMutableDictionary dictionary];
  _count=[definitionsIncludes_ count];
  if (_count>0)
    {
      NSDictionary* tmpDefinitions=nil;
      int i=0;
      NSString* _includeName=nil;
      for(i=_count-1;localDefinitions && i>=0;i--)
        {
          _includeName=[definitionsIncludes_ objectAtIndex:i];
          NSDebugMLLog(@"low",@"Template componentDefinition _includeName:%@",
                       _includeName);
          tmpDefinitions=[self parseDefinitionInclude:_includeName
                               fromFrameworkNamed:localFrameworkName_
                               processedFiles:processedFiles];
          NSDebugMLLog(@"low",@"Template componentDefinition _includeName:%@ tmpDefinitions=%@",
                       _includeName,
                       tmpDefinitions);
          if (tmpDefinitions)
            [localDefinitions addDefaultEntriesFromDictionary:tmpDefinitions];
          else
            {
              localDefinitions=nil;
              LOGError(@"%@ Template componentDefinition parse failed for _includeName:%@",
                       [self logPrefix],
                       _includeName);
            };
        };
    };
  NSDebugMLLog(@"low",@"localDefinitions:%@\n",localDefinitions);
  if (localDefinitions)
    returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

@end

