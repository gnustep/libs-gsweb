/** GSWTemplateParser.m - <title>GSWeb: Class GSWTemplateParser</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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
#include <gsantlr/ANTLRCommon.h>
#include <gsantlr/ANTLRTextStreams.h>
#include "GSWPageDefLexer.h"
#include "GSWPageDefParser.h"
#include "GSWPageDefParserExt.h"

//====================================================================
@implementation GSWTemplateParser

+(void)initialize
{
  if (self == [GSWTemplateParser class])
    {
    };
};

+(GSWTemplateParserType)templateParserTypeFromString:(NSString*)string
{
  GSWTemplateParserType type=0;
  if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XMLHTML] == NSOrderedSame)
    type=GSWTemplateParserType_XMLHTML;
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XMLHTMLNoOmittedTags] == NSOrderedSame)
    type=GSWTemplateParserType_XMLHTMLNoOmittedTags;
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XML] == NSOrderedSame)
    type=GSWTemplateParserType_XML;
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_ANTLR] == NSOrderedSame)
    type=GSWTemplateParserType_ANTLR;
  else 
    type=GSWTemplateParserType_XMLHTML;
  return type;
}

+(GSWTemplateParserType)defaultTemplateParserType
{
  return [self templateParserTypeFromString:[GSWApplication defaultTemplateParser]];
}

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
            parserClassName:(NSString*)parserClassName
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)anEncoding
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)someLanguages
             definitionPath:(NSString*)aDefinitionPath
{
  GSWElement* resultTemplate=nil;
  Class parserClass=Nil;
  LOGClassFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"aDefinitionPath=%@",aDefinitionPath);
  if (parserClassName)
    {
      parserClass=NSClassFromString(parserClassName);
      NSAssert1(parserClass,@"No Parser class named %@",parserClassName);
    };
  resultTemplate=[self templateNamed:aName
                       inFrameworkNamed:aFrameworkName
                       withParserType:(GSWTemplateParserType)parserType
                       parserClass:parserClass
                       withString:HTMLString
                       encoding:anEncoding
                       fromPath:HTMLPath
                       definitionsString:pageDefString
                       languages:someLanguages
                       definitionPath:aDefinitionPath];
  LOGClassFnStop();
  return resultTemplate;
};

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
                parserClass:(Class)parserClass
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)anEncoding
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)someLanguages
             definitionPath:(NSString*)aDefinitionPath
{
  GSWElement* resultTemplate=nil;
  GSWTemplateParser* templateParser=nil;
  Class finalParserClass=Nil;
  LOGClassFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"template named:%@ frameworkName:%@ pageDefString=%@",aName,aFrameworkName,pageDefString);
  NSDebugMLLog(@"GSWTemplateParser",@"aDefinitionPath=%@",aDefinitionPath);
  NSDebugMLLog(@"GSWTemplateParser",@"parserClass:%@ parserType:%d",parserClass,parserType);
/*  if (!parserClass)
    {
      parserClass=[self defaultParserClass];
      NSAssert(parserClass,@"No defaultParser Class");
    };
*/
  if (parserClass)
    finalParserClass=parserClass;
  else
    {
      if (parserType==GSWTemplateParserType_Default)
        parserType=[self defaultTemplateParserType];
      switch(parserType)
        {
        case GSWTemplateParserType_XMLHTML:
        case GSWTemplateParserType_XMLHTMLNoOmittedTags:
          finalParserClass=[GSWTemplateParserXMLHTML class];
          break;
        case GSWTemplateParserType_XML:
          finalParserClass=[GSWTemplateParserXML class];
          break;
        case GSWTemplateParserType_ANTLR:
          finalParserClass=[GSWTemplateParserANTLR class];
          break;
        default:
          finalParserClass=[GSWTemplateParserXMLHTML class];
          break;
        };
    };
  NSDebugMLLog(@"GSWTemplateParser",@"finalParserClass:%@ parserType:%d",finalParserClass,parserType);
  NSAssert2(finalParserClass,@"No Final Parser class: parserClass:%@ parserType:%d",
            parserClass,parserType);
  templateParser=[[[finalParserClass alloc] initWithTemplateName:aName
                                            inFrameworkName:aFrameworkName
                                            withString:HTMLString
                                            encoding:anEncoding
                                            fromPath:HTMLPath
                                            withDefinitionsString:pageDefString
                                            fromPath:aDefinitionPath
                                            forLanguages:someLanguages] autorelease];
  if (templateParser)
    {
      if (!parserClass && parserType==GSWTemplateParserType_XMLHTMLNoOmittedTags)
        [(GSWTemplateParserXMLHTML*)templateParser setNoOmittedTags:YES];
      resultTemplate=[templateParser template];
    };
  LOGClassFnStop();
  return resultTemplate;
};

//--------------------------------------------------------------------
-(id)initWithTemplateName:(NSString*)aName
          inFrameworkName:(NSString*)aFrameworkName
               withString:(NSString*)HTMLString
                 encoding:(NSStringEncoding)anEncoding
                 fromPath:(NSString*)HTMLPath
    withDefinitionsString:(NSString*)pageDefString
                 fromPath:(NSString*)aDefinitionPath
             forLanguages:(NSArray*)someLanguages
{
  if ((self=[self init]))
    {
      ASSIGN(_templateName,aName);
      ASSIGN(_frameworkName,aFrameworkName);
      ASSIGN(_string,HTMLString);
      _stringEncoding=anEncoding;
      ASSIGN(_stringPath,HTMLPath);
      ASSIGN(_definitionsString,pageDefString);
      ASSIGN(_languages,someLanguages);
      ASSIGN(_definitionFilePath,aDefinitionPath);
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
  DESTROY(_processedDefinitionFilePaths);
  DESTROY(_template);
  DESTROY(_definitions);
  DESTROY(_errorMessages);
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
-(void)addErrorMessage:(NSString*)errorMessage
{
  if (!_errorMessages)
    _errorMessages=(NSMutableArray*)[NSMutableArray new];
  [_errorMessages addObject:[NSString stringWithFormat:@"%@%@",
                                      [self logPrefix],
                                      errorMessage]];
};

//--------------------------------------------------------------------
-(void)addErrorMessageFormat:(NSString*)format
                   arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:format
                             arguments:arguments];
  [self addErrorMessage:string];
}

//--------------------------------------------------------------------
-(void)addErrorMessageFormat:(NSString*)format,...
{
  va_list ap=NULL;
  va_start(ap,format);
  [self addErrorMessageFormat:format
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(NSMutableArray*)errorMessages
{
  return _errorMessages;
};

//--------------------------------------------------------------------
-(NSString*)errorMessagesAsText
{
  return [[self errorMessages]componentsJoinedByString:@"\n"];
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
            NSDebugMLLog(@"GSWTemplateParser",@"template named:%@ definitionsElements=%@",aName,definitionsElements);
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
              NSRange docTypeRangeStart=NSMakeRange(NSNotFound,0);
              NSRange docTypeRangeEnd=NSMakeRange(NSNotFound,0);
              
              _template=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements];
              [_template setDefinitionName:[NSString stringWithFormat:@"Template - %@",_templateName]];
              NSDebugMLLog(@"GSWTemplateParser",@"template %p=%@",_template,_template);
              //NSLog(@"_string = %@", _string);
              
              docTypeRangeStart=[_string rangeOfString:@"<!DOCTYPE"];
              if (docTypeRangeStart.length) {
                docTypeRangeEnd=[_string rangeOfString:@">"];
                if (docTypeRangeEnd.length) {
                  if (docTypeRangeStart.location < docTypeRangeEnd.location) 
                    {
                      [_template setDocumentTypeString:[_string substringFromRange:NSMakeRange(docTypeRangeStart.location,
                                                                                               docTypeRangeEnd.location - docTypeRangeStart.location + 1)]];
                    }
                }
              }
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
      NSDebugMLLog(@"GSWTemplateParser",@"_definitionFilePath=%@",_definitionFilePath);
      if ([_definitionsString length]==0)
        {
          ASSIGN(_definitions,[NSDictionary dictionary]);
        }
      else
        {
	  NSDictionary *tmpDefinitions;

          DESTROY(_processedDefinitionFilePaths);
          ASSIGN(_processedDefinitionFilePaths,[NSMutableSet setWithObject:_definitionFilePath]);

          tmpDefinitions = [self parseDefinitionsString:_definitionsString
				 named:_templateName
				 inFrameworkNamed:_frameworkName
				 processedFiles:_processedDefinitionFilePaths];

          if (tmpDefinitions)
            ASSIGN(_definitions,[NSDictionary dictionaryWithDictionary:tmpDefinitions]);
        };
    };
  LOGObjectFnStop();
  return _definitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)parseDefinitionsString:(NSString*)aLocalDefinitionString
                                 named:(NSString*)aLocalDefinitionName
                      inFrameworkNamed:(NSString*)aLocalFrameworkName
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
  definitionsStream=[[ANTLRTextInputStreamString newWithString:aLocalDefinitionString]
                      autorelease];
  definitionsLexer=[[[GSWPageDefLexer alloc]initWithTextStream:definitionsStream]
                     autorelease];
  definitionsTokenBuffer=[ANTLRTokenBuffer tokenBufferWithTokenizer:definitionsLexer];
  definitionsParser=[[[GSWPageDefParser alloc] initWithTokenBuffer:definitionsTokenBuffer]
                      autorelease];
  NSDebugMLLog(@"GSWTemplateParser",@"processedFiles=%@",processedFiles);
  NSDebugMLLog(@"GSWTemplateParser",@"name:%@ definitionsString=%@",
               aLocalDefinitionName,
               aLocalDefinitionString);
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
                         aLocalDefinitionName,
                         [definitionsParser errors],
                         aLocalDefinitionString);
        };
      NSDebugMLLog0(@"low",@"Call [definitionsParser elements]");
      tmpDefinitions=[[[definitionsParser elements] mutableCopy] autorelease];
      definitionsIncludes=[definitionsParser includes];
      NSDebugMLLog0(@"low",@"Definitions Parse OK!");
      NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions=%@",tmpDefinitions);
      NSDebugMLLog(@"GSWTemplateParser",@"definitionsIncludes=%@",definitionsIncludes);
    }
  NS_HANDLER
    {
      LOGError(@"%@ name:%@ Definitions Parse failed!",
               [self logPrefix],
               aLocalDefinitionName);
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
      NSDebugMLLog(@"GSWTemplateParser",@"definitionsIncludes:%@\n",definitionsIncludes);
      NSDebugMLLog(@"GSWTemplateParser",@"aLocalDefinitionName:%@\n",aLocalDefinitionName);
      NSDebugMLLog(@"GSWTemplateParser",@"aLocalFrameworkName:%@\n",aLocalFrameworkName);
      NSDebugMLLog(@"GSWTemplateParser",@"processedFiles:%@\n",processedFiles);
      tmpDefinitions=[self processIncludes:definitionsIncludes
                           named:aLocalDefinitionName
                           inFrameworkNamed:aLocalFrameworkName
                           processedFiles:processedFiles];
      NSDebugMLLog(@"GSWTemplateParser",@"tmpDefinitions:%@\n",tmpDefinitions);
      if (tmpDefinitions)
        [localDefinitions addDefaultEntriesFromDictionary:tmpDefinitions];			  
      else
        {
          localDefinitions=nil;
          LOGError(@"%@ Template name:%@ componentDefinition parse failed for definitionsIncludes:%@",
                   [self logPrefix],
                   aLocalDefinitionName,
                   definitionsIncludes);
        };
      NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions:%@\n",localDefinitions);
    };
  NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions:%@\n",localDefinitions);
  if (localDefinitions)
    returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)parseDefinitionInclude:(NSString*)anIncludeName
                    fromFrameworkNamed:(NSString*)fromFrameworkName
                        processedFiles:(NSMutableSet*)processedFiles
{
  NSDictionary* returnedLocalDefinitions=nil;
  NSMutableDictionary* localDefinitions=nil;
  NSDictionary* tmpDefinitions=nil;
  NSString* localFrameworkName=nil;
  NSString* localDefinitionName=nil;
  NSString* language=nil;
  NSString* resourceName=nil;
  NSString* localDefinitionResourceName=nil;
  GSWResourceManager* resourceManager=nil;
  NSString* path=nil;
  int iLanguage=0;
  int iName=0;
  BOOL isPathAlreadyProcessed=NO;

  LOGObjectFnStart();  


  NSDebugMLLog(@"gswcomponents",@"anIncludeName=%@",anIncludeName);
  resourceManager=[GSWApp resourceManager];
  localDefinitionName=[anIncludeName lastPathComponent];
  localFrameworkName=[anIncludeName stringByDeletingLastPathComponent];
  NSDebugMLLog(@"gswcomponents",@"localFrameworkName=%@",localFrameworkName);
  NSDebugMLLog(@"gswcomponents",@"fromFrameworkName=%@",fromFrameworkName);
  if ([localFrameworkName length]==0)
    localFrameworkName=fromFrameworkName;
  NSDebugMLLog(@"gswcomponents",@"localFrameworkName=%@",localFrameworkName);

  for(iLanguage=0;iLanguage<=[_languages count] && !path;iLanguage++)
    {
      if (iLanguage<[_languages count])
        language=[_languages objectAtIndex:iLanguage];
      else
        language=nil;
      for(iName=0;!path && iName<2;iName++)
        {
          resourceName=[localDefinitionName stringByAppendingString:GSWPagePSuffix[GSWebNamingConvForRound(iName)]];
          localDefinitionResourceName=[localDefinitionName stringByAppendingString:GSWComponentDefinitionPSuffix[GSWebNamingConvForRound(iName)]];
          NSDebugMLLog(@"gswcomponents",@"resourceName=%@ localDefinitionResourceName=%@ localDefinitionName=%@",
                       resourceName,
                       localDefinitionResourceName,
                       localDefinitionName);
          NSDebugMLLog(@"gswcomponents",@"Search %@ Language=%@",resourceName,language);
          path=[resourceManager pathForResourceNamed:resourceName
                                  inFramework:localFrameworkName
                                  language:language];
          NSDebugMLLog(@"gswcomponents",@"Search In Page Component: language=%@ path=%@ processedFiles=%@",
                       language,
                       path,
                       processedFiles);
          if (path)
            {
              path=[path stringByAppendingPathComponent:localDefinitionResourceName];
              NSDebugMLLog(@"gswcomponents",@"Found %@ Language=%@ : %@",resourceName,language,path);
              if ([processedFiles containsObject:path])
                {
                  NSDebugMLLog(@"gswcomponents",@"path=%@ already processed",path);
                  path=nil;
                  isPathAlreadyProcessed=YES;
                  if (language)
                    iLanguage=[_languages count]-1;//For directly go to no language search  so we don't include (for exemple) an English file for a french file
                };
            };
          if (!path)
            {
              NSDebugMLLog(@"gswcomponents",@"Direct Search %@ Language=%@",localDefinitionResourceName,language);
              path=[resourceManager pathForResourceNamed:localDefinitionResourceName
                                      inFramework:localFrameworkName
                                      language:language];
              if (path)
                {
                  NSDebugMLLog(@"gswcomponents",@"Direct Found %@ Language=%@ : %@",localDefinitionResourceName,language,path);
                  if ([processedFiles containsObject:path])
                    {
                      NSDebugMLLog(@"gswcomponents",@"path=%@ already processed",path);
                      path=nil;
                      isPathAlreadyProcessed=YES;
                      if (language)
                        iLanguage=[_languages count]-1;//For directly go to no language search  so we don't include (for exemple) an English file for a french file
                    };
                };
              NSDebugMLLog(@"gswcomponents",@"Direct Search in Component Definition language=%@ path=%@ (processedFiles=%@)",
                           language,
                           path,
                           processedFiles);
            };          
          NSDebugMLLog(@"gswcomponents",@"Search In Page Component: language=%@ path=%@ processedFiles=%@",
                       language,
                       path,
                       processedFiles);
        };
    };
  if (path)
    {
      NSString* pageDefString=nil;
      NSDebugMLLog(@"GSWTemplateParser",@"path=%@",path);
      [processedFiles addObject:path];
      //NSString* pageDefPath=[path stringByAppendingString:_definitionPath];
      //TODO use encoding !
      pageDefString=[NSString stringWithContentsOfFile:path];
      NSDebugMLLog(@"GSWTemplateParser",@"path=%@: pageDefString:%@\n",path,pageDefString);
      if (pageDefString)
        {
          tmpDefinitions=[self parseDefinitionsString:pageDefString
                               named:anIncludeName
                               inFrameworkNamed:localFrameworkName
                               processedFiles:processedFiles];
          NSDebugMLLog(@"GSWTemplateParser",@"tmpDefinitions:%@\n",tmpDefinitions);
          if (tmpDefinitions)
            localDefinitions=[NSMutableDictionary dictionaryWithDictionary:tmpDefinitions];
          else
            {
              LOGError(@"%@ Template componentDefinition parse failed for included file:%@ in framework:%@ (processedFiles=%@)",
                       [self logPrefix],
                       anIncludeName,
                       localFrameworkName,
                       processedFiles);
            };
          NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions:%@\n",localDefinitions);
        }
      else
        {
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Can't load included component definition named:%@ in framework:%@ (processedFiles=%@)",
                         [self logPrefix],
                         anIncludeName,
                         localFrameworkName,
                         processedFiles);
        };
      NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions:%@\n",localDefinitions);
      if (localDefinitions)
        returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
    }
  else if (isPathAlreadyProcessed)
    returnedLocalDefinitions=[NSDictionary dictionary];//return an empty dictionary
  else
    {
      ExceptionRaise(@"GSWTemplateParser",
                     @"%@ Can't find included component definition named:%@ in framework:%@ (processedFiles=%@)",
                     [self logPrefix],
                     anIncludeName,
                     localFrameworkName,
                     processedFiles);
    };
  NSDebugMLLog(@"GSWTemplateParser",@"returnedLocalDefinitions:%@\n",returnedLocalDefinitions);
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

//--------------------------------------------------------------------
-(NSDictionary*)processIncludes:(NSArray*)someDefinitionsIncludes
                          named:(NSString*)aLocalDefinitionsName
               inFrameworkNamed:(NSString*)aLocalFrameworkName
                 processedFiles:(NSMutableSet*)processedFiles
{
  int count=0;
  NSDictionary* returnedLocalDefinitions=nil;
  NSMutableDictionary* localDefinitions=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"name:%@ aFrameworkName=%@ someDefinitionsIncludes=%@",
               aLocalDefinitionsName,
               aLocalFrameworkName,
               someDefinitionsIncludes);
  localDefinitions=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  count=[someDefinitionsIncludes count];
  if (count>0)
    {
      NSDictionary* tmpDefinitions=nil;
      int i=0;
      NSString* includeName=nil;
      for(i=count-1;localDefinitions && i>=0;i--)
        {
          includeName=[someDefinitionsIncludes objectAtIndex:i];
          NSDebugMLLog(@"GSWTemplateParser",@"Template componentDefinition includeName:%@",
                       includeName);
          tmpDefinitions=[self parseDefinitionInclude:includeName
                               fromFrameworkNamed:aLocalFrameworkName
                               processedFiles:processedFiles];
          NSDebugMLLog(@"GSWTemplateParser",@"Template componentDefinition includeName:%@ tmpDefinitions=%@",
                       includeName,
                       tmpDefinitions);
          if (tmpDefinitions)
            [localDefinitions addDefaultEntriesFromDictionary:tmpDefinitions];
          else
            {
              localDefinitions=nil;
              LOGError(@"%@ Template componentDefinition parse failed for includeName:%@",
                       [self logPrefix],
                       includeName);
            };
        };
    };
  NSDebugMLLog(@"GSWTemplateParser",@"localDefinitions:%@\n",localDefinitions);
  if (localDefinitions)
    returnedLocalDefinitions=[NSDictionary dictionaryWithDictionary:localDefinitions];
  LOGObjectFnStop();
  return returnedLocalDefinitions;
};

@end

