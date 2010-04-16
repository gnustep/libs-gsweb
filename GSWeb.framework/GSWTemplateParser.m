/** GSWTemplateParser.m - <title>GSWeb: Class GSWTemplateParser</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$
   $Id$
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWTemplateParser

//--------------------------------------------------------------------
+(void)initialize
{
  if (self == [GSWTemplateParser class])
    {
    };
};

//--------------------------------------------------------------------
+(GSWTemplateParserType)templateParserTypeFromString:(NSString*)string
{
  GSWTemplateParserType type=0;
  if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_RawHTML] == NSOrderedSame)
    type=GSWTemplateParserType_RawHTML;
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XMLHTML] == NSOrderedSame)
    {
      NSWarnLog(@"XMLHTL parser is no more handled. Using RawHTML one");
      type=GSWTemplateParserType_RawHTML;
    }
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XMLHTMLNoOmittedTags] == NSOrderedSame)
    {
      NSWarnLog(@"XMLHTMLNoOmittedTags parser is no more handled. Using RawHTML one");
      type=GSWTemplateParserType_RawHTML;
    }
  else if ([string caseInsensitiveCompare:GSWOPTValue_DefaultTemplateParser_XML] == NSOrderedSame)
    {
      NSWarnLog(@"XML parser is no more handled. Using RawHTML one");
      type=GSWTemplateParserType_RawHTML;
    }
  else 
    type=GSWTemplateParserType_RawHTML;
  NSDebugMLog(@"templateParserTypeFromString:%@ ==> %d",string,type);
  return type;
}

//--------------------------------------------------------------------
+(GSWTemplateParserType)defaultTemplateParserType
{
  return [self templateParserTypeFromString:[GSWApplication defaultTemplateParser]];
}

//--------------------------------------------------------------------
+(GSWElement*)templateWithHTMLString:(NSString *)HTMLString
                   declarationString:(NSString *)declarationsString
                           languages:(NSArray *)languages
{
  return [self templateNamed: nil
               inFrameworkNamed: nil
               withParserType: [self defaultTemplateParserType]
               parserClassName: nil
               withString: HTMLString
               encoding: GSUndefinedEncoding
               fromPath: nil
               declarationsString: declarationsString
               languages: languages
               declarationsPath: nil];
}

//--------------------------------------------------------------------
+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
            parserClassName:(NSString*)parserClassName
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)anEncoding
                   fromPath:(NSString*)HTMLPath
          declarationsString:(NSString*)declarationsString
                  languages:(NSArray*)someLanguages
             declarationsPath:(NSString*)aDeclarationsPath
{
  GSWElement* resultTemplate=nil;
  Class parserClass=Nil;
  LOGClassFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"aDeclarationsPath=%@",aDeclarationsPath);
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
                       declarationsString:declarationsString
                       languages:someLanguages
                       declarationsPath:aDeclarationsPath];
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
         declarationsString:(NSString*)declarationsString
                  languages:(NSArray*)someLanguages
           declarationsPath:(NSString*)aDeclarationsPath
{
  GSWElement* resultTemplate=nil;
  GSWTemplateParser* templateParser=nil;
  Class finalParserClass=Nil;

  LOGClassFnStart();

  NSDebugMLLog(@"GSWTemplateParser",
               @"template named:%@ frameworkName:%@ declarationsString=%@",
               aName,aFrameworkName,declarationsString);

  NSDebugMLLog(@"GSWTemplateParser",
               @"aDeclarationsPath=%@",aDeclarationsPath);

  NSDebugMLLog(@"GSWTemplateParser",
               @"parserClass:%@ parserType:%d",
               parserClass,parserType);

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
          NSWarnLog(@"XMLHTML parser is no more handled. Using RawHTML one");
          finalParserClass=[GSWHTMLTemplateParser class];
          break;
        case GSWTemplateParserType_XML:
          NSWarnLog(@"XML parser is no more handled. Using RawHTML one");
          finalParserClass=[GSWHTMLTemplateParser class];
          break;
        case GSWTemplateParserType_RawHTML:
          finalParserClass=[GSWHTMLTemplateParser class];
          break;
        default:
          finalParserClass=[GSWHTMLTemplateParser class];
          break;
        };
    };

  NSDebugMLLog(@"GSWTemplateParser",
               @"finalParserClass:%@ parserType:%d",
               finalParserClass,parserType);

  NSAssert2(finalParserClass,@"No Final Parser class: parserClass:%@ parserType:%d",
            parserClass,parserType);

  templateParser=[[[finalParserClass alloc] initWithTemplateName:aName
                                            inFrameworkName:aFrameworkName
                                            withString:HTMLString
                                            encoding:anEncoding
                                            fromPath:HTMLPath
                                            withDeclarationsString:declarationsString
                                            fromPath:aDeclarationsPath
                                            forLanguages:someLanguages] autorelease];
  if (templateParser)
    {
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
    withDeclarationsString:(NSString*)declarationsString
                 fromPath:(NSString*)aDeclarationsPath
             forLanguages:(NSArray*)someLanguages
{
  if ((self=[self init]))
    {
      ASSIGN(_templateName,aName);
      ASSIGN(_frameworkName,aFrameworkName);
      ASSIGN(_string,HTMLString);
      _stringEncoding=anEncoding;
      ASSIGN(_stringPath,HTMLPath);
      ASSIGN(_declarationsString,declarationsString);
      ASSIGN(_languages,someLanguages);
      ASSIGN(_declarationsFilePath,aDeclarationsPath);
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
  DESTROY(_declarationsString);
  DESTROY(_languages);
  DESTROY(_declarationsFilePath);
  DESTROY(_processedDeclarationsFilePaths);
  DESTROY(_template);
  DESTROY(_declarations);
  DESTROY(_errorMessages);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)logPrefix
{
  return [NSString stringWithFormat:@"%@:Template Parser for template named %@ in framework %@ \nat %@ - ",
		   NSStringFromClass(isa),
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
  va_list ap;
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
/** parse the template if it's not done and returns it 
May raise exception
**/
-(GSWElement*)template
{
  LOGObjectFnStart();
  if (!_template)
    {
      NSArray* elements=nil;
      NSDictionary* declarations=nil;
      declarations=[self declarations];
      if (!declarations)
        {
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Can't get declarations",
                         [self logPrefix]);
        }
      else
        {
          /*
            NSMutableArray* _classes=[NSMutableArray array];
            BOOL createClassesOk=NO;
            NSEnumerator* _enum = [declarationsElements objectEnumerator];
            id _obj=nil;
            NSString* _className=nil;
            NSDebugMLLog(@"GSWTemplateParser",@"template named:%@ declarationsElements=%@",aName,declarationsElements);
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
              [_template setDeclarationName:[NSString stringWithFormat:@"Template - %@",_templateName]];

              NSDebugMLLog(@"GSWTemplateParser",
                           @"template %p=%@",_template,_template);
              
              docTypeRangeStart=[_string rangeOfString:@"<!DOCTYPE"];
              if (docTypeRangeStart.length) {
                docTypeRangeEnd=[_string rangeOfString:@">"];
                if (docTypeRangeEnd.length) {
                  if (docTypeRangeStart.location < docTypeRangeEnd.location) 
                    {
                      [(GSWHTMLStaticGroup*)_template setDocumentTypeString:
                                              [_string substringFromRange:
                                                         NSMakeRange(docTypeRangeStart.location,
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
/** returns declarations from includedFilePath included from 
declaration file in framework named frameworkName

Method for GSWDeclarationParserPragmaDelegate protocol
**/
-(NSDictionary*)includedDeclarationsFromFilePath:(NSString*)includedFilePath
                              fromFrameworkNamed:(NSString*)frameworkName
{
  NSDictionary* declarations=nil;

  NSString* declarationFrameworkName=nil;
  NSString* declarationFileName=nil;
  GSWResourceManager* resourceManager=nil;
  NSString* path=nil;
  int iLanguage=0;
  BOOL isPathAlreadyProcessed=NO;

  LOGObjectFnStart();  

  NSDebugMLLog(@"GSWTemplateParser",
               @"Template includedDeclarationsFromFilePath:%@",
               includedFilePath);

  resourceManager=[GSWApp resourceManager];

  declarationFileName=[includedFilePath lastPathComponent];
  declarationFrameworkName=[includedFilePath stringByDeletingLastPathComponent];

  NSDebugMLLog(@"gswcomponents",
               @"Template includedDeclarationsFromFilePath: '%@' declarationFileName=%@",
               includedFilePath,declarationFileName);

  NSDebugMLLog(@"gswcomponents",
               @"Template includedDeclarationsFromFilePath: '%@' declarationFrameworkName=%@",
               includedFilePath,declarationFrameworkName);

  if ([declarationFrameworkName length]==0)
    {
      declarationFrameworkName=frameworkName;
      if ([declarationFrameworkName length]==0)
        {  
          declarationFrameworkName=_frameworkName;
        };
    };

  NSDebugMLLog(@"gswcomponents",
               @"declarationFrameworkName=%@",
               declarationFrameworkName);

  for(iLanguage=0;iLanguage<=[_languages count] && !path;iLanguage++)
    {
      NSString* language=nil;
      int iName=0;
      if (iLanguage<[_languages count])
        language=[_languages objectAtIndex:iLanguage];
      else
        language=nil;
      for(iName=0;!path && iName<2;iName++)
        {
          NSString* resourceName=nil;
          NSString* completeResourceName=nil;
          resourceName=[declarationFileName stringByAppendingString:
                                              GSWPagePSuffix[GSWebNamingConvForRound(iName)]];
          completeResourceName=[declarationFileName stringByAppendingString:
                                                             GSWComponentDeclarationsPSuffix[GSWebNamingConvForRound(iName)]];
          NSDebugMLLog(@"gswcomponents",
                       @"resourceName=%@ completeResourceName=%@ declarationFileName=%@",
                       resourceName,
                       completeResourceName,
                       declarationFileName);

          NSDebugMLLog(@"gswcomponents",
                       @"Search %@ Language=%@",resourceName,language);

          path=[resourceManager pathForResourceNamed:resourceName
                                  inFramework:declarationFrameworkName
                                  language:language];
          NSDebugMLLog(@"gswcomponents",
                       @"Search In Page Component: language=%@ path=%@ _processedDeclarationsFilePaths=%@",
                       language,
                       path,
                       _processedDeclarationsFilePaths);
          if (path)
            {
              path=[path stringByAppendingPathComponent:completeResourceName];
              NSDebugMLLog(@"gswcomponents",@"Found %@ Language=%@ : %@",resourceName,language,path);

              if ([_processedDeclarationsFilePaths containsObject:path])
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
              NSDebugMLLog(@"gswcomponents",
                           @"Direct Search %@ Language=%@",
                           completeResourceName,language);

              path=[resourceManager pathForResourceNamed:completeResourceName
                                    inFramework:declarationFrameworkName
                                    language:language];
              if (path)
                {
                  NSDebugMLLog(@"gswcomponents",
                               @"Direct Found %@ Language=%@ : %@",
                               completeResourceName,language,path);

                  if ([_processedDeclarationsFilePaths containsObject:path])
                    {
                      NSDebugMLLog(@"gswcomponents",
                                   @"path=%@ already processed",path);
                      path=nil;
                      isPathAlreadyProcessed=YES;
                      if (language)
                        iLanguage=[_languages count]-1;//For directly go to no language search  so we don't include (for exemple) an English file for a french file
                    };
                };
              NSDebugMLLog(@"gswcomponents",
                           @"Direct Search in Component Declaration language=%@ path=%@ (_processedDeclarationsFilePaths=%@)",
                           language,
                           path,
                           _processedDeclarationsFilePaths);
            };          
          NSDebugMLLog(@"gswcomponents",
                       @"Search In Page Component: language=%@ path=%@ _processedDeclarationsFilePaths=%@",
                       language,
                       path,
                       _processedDeclarationsFilePaths);
        };
    };

  if (path)
    {
      NSString* declarationsString=nil;

      NSDebugMLLog(@"GSWTemplateParser",@"path=%@",path);

      [_processedDeclarationsFilePaths addObject:path];

      //NSString* pageDefPath=[path stringByAppendingString:_declarationsPath];
      //TODO use encoding !

      declarationsString=[NSString stringWithContentsOfFile:path];

      NSDebugMLLog(@"GSWTemplateParser",
                   @"ParseDeclarations path=%@: declarationsString:%@\n",path,declarationsString);

      if (declarationsString)
        {
          declarations=[self parseDeclarationsString:declarationsString
                             named:declarationFileName
                             inFrameworkNamed:declarationFrameworkName];

          NSDebugMLLog(@"GSWTemplateParser",
                       @"declarations:%@\n",declarations);

          if (!declarations)
            {
              LOGError(@"%@ Template componentDeclaration parse failed for "
                       @"included file:%@ in framework:%@ (processedFiles=%@)",
                       [self logPrefix],
                       declarationFileName,
                       declarationFrameworkName,
                       _processedDeclarationsFilePaths);
            };
          NSDebugMLLog(@"GSWTemplateParser",@"declarations:%@\n",declarations);
        }
      else
        {
          ExceptionRaise(@"GSWTemplateParser",
                         @"%@ Can't load included component declaration "
                         @"named:%@ in framework:%@ (_processedDeclarationsFilePaths=%@)",
                         [self logPrefix],
                         declarationFileName,
                         declarationFrameworkName,
                         _processedDeclarationsFilePaths);
        };
      NSDebugMLLog(@"GSWTemplateParser",@"declarations:%@\n",declarations);
    }
  else if (isPathAlreadyProcessed)
    {
      // Returns an empty dictionary
      declarations=[NSDictionary dictionary];
    }
  else
    {
      ExceptionRaise(@"GSWTemplateParser",
                     @"%@ Can't find included component declaration "
                     @"named:%@ in framework:%@ (processedFiles=%@)",
                     [self logPrefix],
                     declarationFileName,
                     declarationFrameworkName,
                     _processedDeclarationsFilePaths);
    };

  NSDebugMLLog(@"GSWTemplateParser",@"Template componentDeclaration "
               @"includeName:%@ declarations=%@",
               includedFilePath,
               declarations);

  LOGObjectFnStop();

  return declarations;
};

//--------------------------------------------------------------------
/** parses declarations from _declarationsString if it has not been 
parsed **/
-(void)parseDeclarations
{
  LOGObjectFnStart();
  if (!_declarations)
    {
      NSDebugMLLog(@"GSWTemplateParser",@"_declarationsFilePath=%@",
		   _declarationsFilePath);
      if ([_declarationsString length]==0)
        {
          ASSIGN(_declarations,[NSDictionary dictionary]);
        }
      else
        {
	  NSDictionary* declarations=nil;

          DESTROY(_processedDeclarationsFilePaths);
          ASSIGN(_processedDeclarationsFilePaths, 
		 (_declarationsFilePath 
		  ? [NSMutableSet setWithObject:_declarationsFilePath]
		  : [NSMutableSet set]));

          NSDebugMLLog(@"GSWTemplateParser",
		       @"ParseDeclarations path=%@: declarationsString:%@\n",
		       _declarationsFilePath,_declarationsString);
          declarations = [self parseDeclarationsString:_declarationsString
                               named:_templateName
                               inFrameworkNamed:_frameworkName];
          
          ASSIGNCOPY(_declarations,declarations);
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** parse declarationsString if it is not already done and returns 
declarations **/
-(NSDictionary*)declarations
{
  LOGObjectFnStart();
  if (!_declarations)
    [self parseDeclarations];
  LOGObjectFnStop();
  return _declarations;
};

//--------------------------------------------------------------------
/** return declarations parsed from declarationsString
**/
-(NSDictionary*)parseDeclarationsString:(NSString*)declarationsString
                                  named:(NSString*)declarationsName
                       inFrameworkNamed:(NSString*)declarationsFrameworkName
{
  NSDictionary* declarations=nil;
  GSWDeclarationParser* declarationParser=nil;
  NSAutoreleasePool* arpParse=nil;

  LOGObjectFnStart();

  arpParse=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",arpParse);

  declarationParser=[GSWDeclarationParser declarationParserWithPragmaDelegate:self];

  NSDebugMLLog(@"GSWTemplateParser",@"name:%@ declarationsString=%@",
               declarationsName,
               declarationsString);
  NS_DURING
    {
      declarations=[declarationParser parseDeclarationString:declarationsString
                                      named:declarationsName
                                      inFrameworkNamed:declarationsFrameworkName];
      NSDebugMLLog(@"GSWTemplateParser",
                   @"declarations=%@",
                   declarations);
    }
  NS_HANDLER
    {
      NSDebugMLog(@"ERROR ! %@",localException);
      NSDebugMLog(@"declarationsName=%@",declarationsName);//TODO
      NSDebugMLog(@"[self logPrefix]=%@",[self logPrefix]);
      LOGError(@"%@ name:%@ Declarations Parse failed!",
               [self logPrefix],
               declarationsName);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"%@ In [declarationsParser document]...",
                                                              [self logPrefix]);
      [localException retain];
      GSWLogMemCF("Destroy NSAutoreleasePool: %p",arpParse);
      DESTROY(arpParse);
      [localException autorelease];
      [localException raise];
    }
  NS_ENDHANDLER;

  NSDebugMLLog0(@"low",@"arpParse infos:\n");
  [declarations retain];

  NSDebugMLLog0(@"low",@"DESTROY(arpParse)\n");
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",arpParse);

  DESTROY(arpParse);

  NSDebugMLLog0(@"low",@"DESTROYED(arpParse)\n");
  [declarations autorelease];
  
  NSDebugMLLog(@"GSWTemplateParser",
               @"declarations:%@\n",
               declarations);

  LOGObjectFnStop();

  return declarations;
};


// those are here because a protocol forces us to implement them -- dw

- (id) retain
{
  return [super retain];
}

- (oneway void)release
{
  return [super release];
}

- (id)autorelease
{
  return [super autorelease];
}



@end

