/** GSWDeclarationParser.m - <title>GSWeb: Class GSWDeclarationParser</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
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

#include "GSWDeclarationParser.h"
#include <GNUstepBase/Unicode.h>
#include <GNUstepBase/GSCategories.h>

static inline BOOL _parserIsIdentifierChar(unichar c)
{
  switch(c)
    {
    case ' ':
    case '\t':
    case '\f':
    case '\r':
    case '\n':
    case '\v':
    case '{':  // Dictionary
    case '}':  // Dictionary
    case '(':  // Array
    case ')':  // Array
    case '<':  // Data
    case '>':  // Data
    case '/':  // Comment
    case ':':  // Separator
    case ';':  // Separator
    case '.':  // Separator
    case ',':  // Separator
    case '=':  // Separator
      return NO;
    default:
      return YES;
    };
};

NSString* const GSWDFEMissingDeclarationForElement = @"GSWDFEMissingDeclarationForElement";
NSString* const GSWDFEMissingElementName = @"GSWDFEMissingElementName";
NSString* const GSWDFEMissingClassNameForElement = @"GSWDFEMissingClassNameForElement";
NSString* const GSWDFEElementCreationFailed = @"GSWDFEElementCreationFailed";
NSString* const GSWDFEMissingIdentifier = @"GSWDFEMissingIdentifier";
NSString* const GSWDFEMissingPragmaDelegate = @"GSWDFEMissingPragmaDelegate";
NSString* const GSWDFEUnknownPragmaDirective = @"GSWDFEUnknownPragmaDirective";
NSString* const GSWDFEMissingQuotedStringEnd = @"GSWDFEMissingQuotedStringEnd";
NSString* const GSWDFEMissingHexStringDataEnd = @"GSWDFEMissingHexStringDataEnd";
NSString* const GSWDFEMissingQuotedKeyPathEnd = @"GSWDFEMissingQuotedKeyPathEnd";
NSString* const GSWDFEWrongKeyPathFormat = @"GSWDFEWrongKeyPathFormat";
NSString* const GSWDFEEmptyKeyPath = @"GSWDFEEmptyKeyPath";
NSString* const GSWDFEWrongNumberFormat = @"GSWDFEWrongNumberFormat";
NSString* const GSWDFEWrongHexNumberFormat = @"GSWDFEWrongHexNumberFormat";
NSString* const GSWDFEUnexpectedBufferEnd = @"GSWDFEUnexpectedBufferEnd";
NSString* const GSWDFEMissingValue = @"GSWDFEMissingValue";
NSString* const GSWDFEMissingSeparator = @"GSWDFEMissingSeparator";
NSString* const GSWDFEDictionaryParsingError = @"GSWDFEDictionaryParsingError";
NSString* const GSWDFEArrayParsingError = @"GSWDFEArrayParsingError";
NSString* const GSWDFEUnexpectedCharacter = @"GSWDFEUnexpectedCharacter";
NSString* const GSWDFEMissingAliasedDeclaration = @"GSWDFEMissingAliasedDeclaration";

static NSSet* delayedDeclarationFormatExceptionNames = nil;
static NSMutableDictionary* declarationsCache=nil;

static SEL skipBlanksSEL = NULL;
static SEL skipCommentSEL = NULL;
static SEL skipBlanksAndCommentsSEL = NULL;
static SEL parsePragmaSEL = NULL;
static SEL parseIdentifierSEL = NULL;
static SEL parseKeySEL = NULL;
static SEL parseQuotedStringSEL = NULL;
static SEL parseHexDataSEL = NULL;
static SEL parseKeyPathSEL = NULL;
static SEL tryParseBooleanSEL = NULL;
static SEL parseNumberSEL = NULL;
static SEL parseHexNumberSEL = NULL;
static SEL parseValueAsAssociationSEL = NULL;
static SEL parseDictionaryWithValuesAsAssociationsSEL = NULL;
static SEL parseArraySEL = NULL;
static SEL parseDeclarationSEL = NULL;

//====================================================================
@implementation GSWDeclarationFormatException

+ (void) initialize
{
  if (self == [GSWDeclarationFormatException class])
    {
      ASSIGN(delayedDeclarationFormatExceptionNames,
             ([NSSet setWithObjects:
                       GSWDFEMissingDeclarationForElement,
                     GSWDFEMissingElementName,
                     GSWDFEMissingClassNameForElement,
                     GSWDFEElementCreationFailed,
                     GSWDFEMissingIdentifier,
                     GSWDFEMissingPragmaDelegate,
                     GSWDFEUnknownPragmaDirective,
                     GSWDFEMissingQuotedStringEnd,
                     GSWDFEMissingHexStringDataEnd,
                     GSWDFEMissingQuotedKeyPathEnd,
                     GSWDFEWrongKeyPathFormat,
                     GSWDFEEmptyKeyPath,
                     GSWDFEWrongNumberFormat,
                     GSWDFEWrongHexNumberFormat,
                     GSWDFEUnexpectedBufferEnd,
                     GSWDFEMissingValue,
                     GSWDFEMissingSeparator,
                     GSWDFEDictionaryParsingError,
                     GSWDFEArrayParsingError,
                     GSWDFEUnexpectedCharacter,
                     nil]));
    };  
};

//--------------------------------------------------------------------
/** Returns YES if we can delay exception reporting (so all errors are 
accumulated instead of blocking on first error) **/
-(BOOL)canDelay
{
  return [delayedDeclarationFormatExceptionNames containsObject:[self name]];
};


@end


// 'Standard' GSWContext class. Used to get IMPs from standardElementIDIMPs
static Class standardClass=Nil;

// List of standardClass IMPs
static GSWDeclarationParserIMPs standardDeclarationParserIMPs;

//====================================================================
/** Fill impsPtr structure with IMPs for declarationParser **/
void GetGSWDeclarationParserIMPS(GSWDeclarationParserIMPs* impsPtr,GSWDeclarationParser* declarationParser)
{
  if ([declarationParser class]==standardClass)
    {
      memcpy(impsPtr,&standardDeclarationParserIMPs,sizeof(GSWDeclarationParserIMPs));
    }
  else
    {
      memset(impsPtr,0,sizeof(GSWDeclarationParserIMPs));

      impsPtr->_skipBlanksIMP = 
        (GSWIMP_BOOL)[declarationParser methodForSelector:skipBlanksSEL];

      impsPtr->_skipCommentIMP = 
        (GSWIMP_BOOL)[declarationParser methodForSelector:skipCommentSEL];

      impsPtr->_skipBlanksAndCommentsIMP = 
        (GSWIMP_BOOL)[declarationParser methodForSelector:skipBlanksAndCommentsSEL];

      impsPtr->_parsePragmaIMP = 
        [declarationParser methodForSelector:parsePragmaSEL];

      impsPtr->_parseIdentifierIMP = 
        [declarationParser methodForSelector:parseIdentifierSEL];

      impsPtr->_parseKeyIMP = 
        [declarationParser methodForSelector:parseKeySEL];

      impsPtr->_parseQuotedStringIMP = 
        [declarationParser methodForSelector:parseQuotedStringSEL];

      impsPtr->_parseHexDataIMP = 
        [declarationParser methodForSelector:parseHexDataSEL];
      
      impsPtr->_parseKeyPathIMP = 
        [declarationParser methodForSelector:parseKeyPathSEL];

      impsPtr->_tryParseBooleanIMP = 
        [declarationParser methodForSelector:tryParseBooleanSEL];
      
      impsPtr->_parseNumberIMP = 
        [declarationParser methodForSelector:parseNumberSEL];

      impsPtr->_parseHexNumberIMP = 
        [declarationParser methodForSelector:parseHexNumberSEL];
      
      impsPtr->_parseValueAsAssociationIMP = 
        [declarationParser methodForSelector:parseValueAsAssociationSEL];

      impsPtr->_parseDictionaryWithValuesAsAssociationsIMP = 
        [declarationParser methodForSelector:parseDictionaryWithValuesAsAssociationsSEL];
      
      impsPtr->_parseArrayIMP = 
        [declarationParser methodForSelector:parseArraySEL];

      impsPtr->_parseDeclarationIMP = 
        [declarationParser methodForSelector:parseDeclarationSEL];      
    };
};

inline BOOL skipBlanks(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._skipBlanksIMP)(parser,skipBlanksSEL));
};

inline BOOL skipComment(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._skipCommentIMP)(parser,skipCommentSEL));
};

inline BOOL skipBlanksAndComments(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._skipBlanksAndCommentsIMP)(parser,skipBlanksAndCommentsSEL));
};

inline void parsePragma(GSWDeclarationParser* parser)
{
  ((*parser->_selfIMPs._parsePragmaIMP)(parser,parsePragmaSEL));
};

inline NSString* parseIdentifier(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseIdentifierIMP)(parser,parseIdentifierSEL));
};

inline NSString* parseKey(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseKeyIMP)(parser,parseKeySEL));
};

inline id parseKeyPath(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseKeyPathIMP)(parser,parseKeyPathSEL));
};

inline id parseQuotedString(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseQuotedStringIMP)(parser,parseQuotedStringSEL));
};

inline NSData* parseHexData(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseHexDataIMP)(parser,parseHexDataSEL));
};

inline NSNumber* tryParseBoolean(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._tryParseBooleanIMP)(parser,tryParseBooleanSEL));
};

inline NSNumber* parseNumber(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseNumberIMP)(parser,parseNumberSEL));
};

inline NSNumber* parseHexNumber(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseHexNumberIMP)(parser,parseHexNumberSEL));
};

inline id parseValueAsAssociation(GSWDeclarationParser* parser,BOOL asAssociation)
{
  return ((*parser->_selfIMPs._parseValueAsAssociationIMP)(parser,parseValueAsAssociationSEL,asAssociation));
};

inline NSDictionary* parseDictionaryWithValuesAsAssociations(GSWDeclarationParser* parser,
                                                             BOOL valuesAsAssociations)
{
  return ((*parser->_selfIMPs._parseDictionaryWithValuesAsAssociationsIMP)(parser,parseDictionaryWithValuesAsAssociationsSEL,valuesAsAssociations));
};

inline NSArray* parseArray(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseArrayIMP)(parser,parseArraySEL));
};

inline GSWDeclaration* parseDeclaration(GSWDeclarationParser* parser)
{
  return ((*parser->_selfIMPs._parseDeclarationIMP)(parser,parseDeclarationSEL));
};


//====================================================================
@implementation GSWDeclarationParser

+ (void) initialize
{
  if (self == [GSWDeclarationParser class])
    {
      declarationsCache=[NSMutableDictionary new];

      standardClass=[GSWDeclarationParser class];

      skipBlanksSEL = @selector(skipBlanks);
      skipCommentSEL = @selector(skipComment);
      skipBlanksAndCommentsSEL = @selector(skipBlanksAndComments);
      parsePragmaSEL = @selector(parsePragma);
      parseIdentifierSEL = @selector(parseIdentifier);
      parseKeySEL = @selector(parseKey);
      parseQuotedStringSEL = @selector(parseQuotedString);
      parseHexDataSEL = @selector(parseHexData);
      parseKeyPathSEL = @selector(parseKeyPath);
      tryParseBooleanSEL = @selector(tryParseBoolean);
      parseNumberSEL = @selector(parseNumber);
      parseHexNumberSEL = @selector(parseHexNumber);
      parseValueAsAssociationSEL = @selector(parseValueAsAssociation:);
      parseDictionaryWithValuesAsAssociationsSEL = @selector(parseDictionaryWithValuesAsAssociations:);
      parseArraySEL = @selector(parseArray);
      parseDeclarationSEL = @selector(parseDeclaration);      

      memset(&standardDeclarationParserIMPs,0,sizeof(GSWDeclarationParserIMPs));

      standardDeclarationParserIMPs._skipBlanksIMP = 
        (GSWIMP_BOOL)[standardClass instanceMethodForSelector:skipBlanksSEL];

      standardDeclarationParserIMPs._skipCommentIMP  =
        (GSWIMP_BOOL)[standardClass instanceMethodForSelector:skipCommentSEL];

      standardDeclarationParserIMPs._skipBlanksAndCommentsIMP = 
        (GSWIMP_BOOL)[standardClass instanceMethodForSelector:skipBlanksAndCommentsSEL];

      standardDeclarationParserIMPs._parsePragmaIMP = 
        [standardClass instanceMethodForSelector:parsePragmaSEL];

      standardDeclarationParserIMPs._parseIdentifierIMP = 
        [standardClass instanceMethodForSelector:parseIdentifierSEL];

      standardDeclarationParserIMPs._parseKeyIMP = 
        [standardClass instanceMethodForSelector:parseKeySEL];

      standardDeclarationParserIMPs._parseQuotedStringIMP = 
        [standardClass instanceMethodForSelector:parseQuotedStringSEL];

      standardDeclarationParserIMPs._parseHexDataIMP = 
        [standardClass instanceMethodForSelector:parseHexDataSEL];
      
      standardDeclarationParserIMPs._parseKeyPathIMP = 
        [standardClass instanceMethodForSelector:parseKeyPathSEL];

      standardDeclarationParserIMPs._tryParseBooleanIMP = 
        [standardClass instanceMethodForSelector:tryParseBooleanSEL];
      
      standardDeclarationParserIMPs._parseNumberIMP = 
        [standardClass instanceMethodForSelector:parseNumberSEL];

      standardDeclarationParserIMPs._parseHexNumberIMP = 
        [standardClass instanceMethodForSelector:parseHexNumberSEL];
      
      standardDeclarationParserIMPs._parseValueAsAssociationIMP = 
        [standardClass instanceMethodForSelector:parseValueAsAssociationSEL];

      standardDeclarationParserIMPs._parseDictionaryWithValuesAsAssociationsIMP = 
        [standardClass instanceMethodForSelector:parseDictionaryWithValuesAsAssociationsSEL];
      
      standardDeclarationParserIMPs._parseArrayIMP = 
        [standardClass instanceMethodForSelector:parseArraySEL];

      standardDeclarationParserIMPs._parseDeclarationIMP = 
        [standardClass instanceMethodForSelector:parseDeclarationSEL];      
    };
};

//--------------------------------------------------------------------
+(GSWDeclarationParser*)declarationParserWithPragmaDelegate:(id<GSWDeclarationParserPragmaDelegate>)pragmaDelegate
{
  return [[[self alloc]
            initWithPragmaDelegate:pragmaDelegate]
           autorelease];
}

//--------------------------------------------------------------------
-(id)initWithPragmaDelegate:(id<GSWDeclarationParserPragmaDelegate>)pragmaDelegate
{
  if ((self=[self init]))
    {
      ASSIGN(_pragmaDelegate,pragmaDelegate);
    };
  return self;
};

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      GetGSWDeclarationParserIMPS(&_selfIMPs,self);
    };
  return self;
};
//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_pragmaDelegate);
  DESTROY(_declarations);
  DESTROY(_fileName);
  DESTROY(_frameworkName);

  [super dealloc];
};

//--------------------------------------------------------------------
-(NSDictionary*)parseDeclarationString:(NSString*)declarationString
                                 named:(NSString*)declarationFileName
                      inFrameworkNamed:(NSString*)declarationFrameworkName
{
  NSData* md5=nil;
  NSDictionary* declarations=nil;
  LOGObjectFnStart();

  if (_declarations)
    [_declarations removeAllObjects];

  ASSIGN(_string,declarationString);
  ASSIGN(_fileName,declarationFileName);
  ASSIGN(_frameworkName,declarationFrameworkName);

  NSDebugMLog(@"declarationString=%@",declarationString);
  _length=[_string length];

  if ([_string rangeOfString:@"#include"].length==0)
    {
      md5=[_string dataUsingEncoding: NSUnicodeStringEncoding];
      md5=[md5 md5Digest];
      declarations=[declarationsCache objectForKey:md5];
      NSDebugMLog(@"declaration (%@) is %scached",declarationFileName,(declarations ? "" : "not "));
    }

  if (!declarations)
    {
      if (!_declarations)
        _declarations=(NSMutableDictionary*)[NSMutableDictionary new];
      
      _uniBuf =  (unichar*)objc_malloc(sizeof(unichar)*(_length+1));
      NS_DURING
        {
          [_string getCharacters:_uniBuf];
      
          NSDebugMLog(@"index=%d length=%d",index,_length);
          //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
          
          while(_index<_length)
            {      
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
              skipBlanksAndComments(self);
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
              if (_index<_length)
                {
                  if (_uniBuf[_index]=='#')
                    {
                      parsePragma(self);
                      NSDebugMLog(@"index=%d _length=%d",_index,20);
                    }
                  else if (_parserIsIdentifierChar(_uniBuf[_index]))
                    {
                      GSWDeclaration* declaration=parseDeclaration(self);
                      NSDebugMLog(@"declaration=%@",declaration);
                      [_declarations setObject:declaration
                                     forKey:[declaration name]];
                      NSDebugMLog(@"index=%d _length=%d",_index,20);
                    }
                  else
                    {
                      [GSWDeclarationFormatException raise:GSWDFEMissingIdentifier
                                                     format:@"In %@ %@: No identifier %@",
                                                     _frameworkName,_fileName,
                                                     [self currentLineAndColumnIndexesString]];
                    };
                };
            }
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
        }
      NS_HANDLER
        {
          if (_uniBuf)
            {
              objc_free(_uniBuf);
              _uniBuf=NULL;
            };
          [localException raise];
        };
      NS_ENDHANDLER;
      
      NSDebugMLog(@"_declarations=%@",_declarations);
      declarations=[NSDictionary dictionaryWithDictionary:_declarations];
      if (md5)
        [declarationsCache setObject:declarations
                           forKey:md5];
    };

  LOGObjectFnStop();

  return declarations;
}

//--------------------------------------------------------------------
-(NSDictionary*)parseDeclarationString:(NSString*)declarationString
{
  NSDictionary* declarations=nil;
  LOGObjectFnStart();

  declarations=[self parseDeclarationString:declarationString
                     named:nil
                     inFrameworkNamed:nil];

  LOGObjectFnStop();

  return declarations;
}


//--------------------------------------------------------------------
/** Returns YES if blank skipped **/
-(BOOL)skipBlanks
{
  int startIndex=_index;
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  while(_index<_length
        && (_parserIsBlankChar(_uniBuf[_index])
            || _parserIsEndOfLineChar(_uniBuf[_index])))
    _index++;
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return (_index>startIndex ? YES : NO);
};

//--------------------------------------------------------------------
/** Returns YES if comments skipped **/
-(BOOL)skipComment
{
  int startIndex=_index;
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  if (_uniBuf[_index]=='/')
    {
      //ParserDebugLogBuffer(_uniBuf,_length,_index+1,10);
      if (_uniBuf[(_index)+1]=='/') // // styles comments
        {
          _index+=2;
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          //TODO Should handle line continuation
          while(_index<_length)
            {
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
              if (_parserIsEndOfLineChar(_uniBuf[_index]))
                {
                  _index++;
                  break;
                }
              else
                _index++;
            };
          //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
        }
      else if (_uniBuf[(_index)+1]=='*') // /* styles comments
        {
          _index+=2;
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          //TODO Should handle line continuation
          while(_index<_length-1)
            {
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
              if (_uniBuf[_index]=='*'
                  && _uniBuf[(_index)+1]=='/')
                {
                  _index+=2;
                  break;
                }
              else
                _index++;
            };
          //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
        }
      else
        _index++;
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return (_index>startIndex ? YES : NO);
}

//--------------------------------------------------------------------
/** Returns YES if blanks or comments skipped **/
-(BOOL)skipBlanksAndComments
{
  BOOL skipped=NO;
  BOOL isLastSkipped=YES;
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  while(_index<_length && isLastSkipped)
    {
      isLastSkipped=skipBlanks(self);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      if (skipComment(self))
        isLastSkipped=YES;
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      if (isLastSkipped)
        skipped=YES;
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return skipped;
};

//--------------------------------------------------------------------
-(void)parsePragma
{
  int startIndex=_index;
  NSString* pragmaDirective=nil;
  NSAssert(_index<_length,@"Reached buffer end parsing a prgma");
  NSAssert1(_uniBuf[_index]=='#',@"First character should be '#', not '%c'",(char)_uniBuf[_index]);

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  while(_index<_length
        && !_parserIsEndOfLineChar(_uniBuf[_index]))
    {
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      _index++;
    };
  pragmaDirective=[NSString stringWithCharacters:_uniBuf+startIndex
                            length:_index-startIndex];
  NSDebugMLog(@"pragmaDirective=%@",pragmaDirective);
  if ([pragmaDirective hasPrefix:@"#include"])
    {
      if (!_pragmaDelegate)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEMissingPragmaDelegate
            format:@"In %@ %@: No pragma delegate for pragma directive '%@'",
            _frameworkName,_fileName];
        }
      else
        {
          NSDictionary* declarations=nil;
          NSString* file=[pragmaDirective stringByDeletingPrefix:@"#include"];
          file=[file stringByTrimmingSpaces];
          if ([file hasPrefix:@"\""])
            file=[[file stringByDeletingPrefix:@"\""]
                   stringByDeletingSuffix:@"\""];
          else if ([file hasPrefix:@"<"])
            file=[[file stringByDeletingPrefix:@"<"]
                   stringByDeletingSuffix:@">"];
          NSDebugMLog(@"pragma include file=%@",file);
          NSDebugMLog(@"pragma _frameworkName=%@",_frameworkName);
          declarations=[_pragmaDelegate includedDeclarationsFromFilePath:file
                                        fromFrameworkNamed:_frameworkName];
          if ([declarations count]>0)
            [_declarations addEntriesFromDictionary:declarations];
        };
    }
  else
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEUnknownPragmaDirective
        format:@"In %@ %@: Unknown pragma directive '%@' at line %@",
        _frameworkName,_fileName,
        [self lineIndexFromIndex:startIndex]];
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
};


//--------------------------------------------------------------------
/** Parse an indentifier.
Index should be on the identifier first character
Returns a NSString
**/
-(NSString*)parseIdentifier
{
  NSString* identifier=nil;
  int startIndex=_index;

  NSAssert(_index<_length,@"Reached buffer end parsing an identifier");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  while(_index<_length
        && _parserIsIdentifierChar(_uniBuf[_index]))
    _index++;

  if (index-startIndex==0)
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEMissingIdentifier
        format:@"IN %@ %@: No identifier %@",
        _frameworkName,_fileName,
        [self currentLineAndColumnIndexesString]];
    }
  else
    {
      identifier=[NSString stringWithCharacters:_uniBuf+startIndex
                           length:_index-startIndex];
      NSDebugMLog(@"identifier=%@",identifier);
    };

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return identifier;
}

//--------------------------------------------------------------------
/** Parse a key.
Index should be on the identifier first character
Returns a NSString
**/
-(NSString*)parseKey
{
  return parseIdentifier(self);
}

//--------------------------------------------------------------------
/** Parse a quoted string.
Index should be on the value first character (")
Returns a NSString without '"' pefix and suffix
**/
-(id)parseQuotedString
{
  NSString *string=nil;
  unsigned startIndex=_index;
  BOOL escaped = NO;

  NSAssert(_index<_length,@"Reached buffer end parsing an quoted string");
  NSAssert(_uniBuf[_index]=='"',@"First character should be '\"'");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  _index++; // skip '"'
  while(_index<_length
        && _uniBuf[_index]!='"')
    {
      if (_uniBuf[_index]=='\\' && (_index+1 < _length))
        {
	  escaped=YES;
	  _index++;
	}
      _index++;
    };
  if (_index<_length && _uniBuf[_index]=='"')
    _index++;
  else
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEMissingQuotedStringEnd
        format:@"In %@ %@: No end '\"' for quoted string starting at line %d",
        _frameworkName,_fileName,
        [self lineIndexFromIndex:startIndex]];
    };  
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  if (escaped)
    {
      unsigned i,j,l = _index-startIndex-2; // don't take '"' prefix and suffix
      unichar *buf = GSAutoreleasedBuffer(sizeof(unichar)*l);
      memcpy (buf, &_uniBuf[startIndex+1], sizeof(unichar)*l);

      for (i=0,j=0;i<l;i++,j++)
        {
	  if (buf[i]=='\\' && (i+1 < l)) i++;
	  buf[j]=buf[i];
	}
      string=[NSString stringWithCharacters:buf length:j];
    }
  else
    {
      string=[NSString stringWithCharacters:_uniBuf+startIndex+1
		       length:_index-startIndex-2]; // don't take '"' prefix and suffix
    }
  return string;
};

//--------------------------------------------------------------------
/** Parse a data <12A1 1213...>
Index should be on the value first character ('<')
Returns a NSData
**/
-(NSData*)parseHexData
{
  NSData* data=nil;
  NSString* string=nil;
  int startIndex=_index;
  NSAssert(_index<_length,@"Reached buffer end parsing a data");
  NSAssert(_uniBuf[_index]=='<',@"First character should be '<'");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  _index++; // skip '<'
  while(_index<_length
        && _uniBuf[_index]!='>')
    {
      _index++;
    };
  if (_index<_length && _uniBuf[_index]=='>')
    _index++;
  else
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEMissingHexStringDataEnd
        format:@"In %@ %@: No end '>' for data starting at line %d",
        _frameworkName,_fileName,
        [self lineIndexFromIndex:startIndex]];
    };  
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  string=[NSString stringWithCharacters:_uniBuf+startIndex+1
                   length:_index-startIndex-2]; // -2 because we don't take < >
  NSDebugMLog(@"string=%@",string);
  data=[[[NSData alloc]initWithHexadecimalRepresentation:string]autorelease];
  NSDebugMLog(@"data=%@",data);

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return data;
};

//--------------------------------------------------------------------
/** Parse a key path
Index should be on the first character
Returns a NSString
**/
-(id)parseKeyPath
{
  NSString* keyPath=nil;
  int startIndex=_index;
  BOOL end=NO;
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  while(!end && _index<_length)
    {
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      switch(_uniBuf[_index])
        {
        case '\'':        
          _index++;
          while(_index<_length
                && _uniBuf[_index]!='\'')
            {
              _index++;
            };
          if (_index<_length && _uniBuf[_index]=='\'')
            _index++;
          else
            {
              [GSWDeclarationFormatException 
                raise:GSWDFEMissingQuotedKeyPathEnd
                format:@"In %@ %@: No end '\'' for keyPath starting at line %d",
                _frameworkName,_fileName,
                [self lineIndexFromIndex:startIndex]];
            };
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          break;
        case '\"':
          _index++;
          while(_index<_length
                && _uniBuf[_index]!='\"')
            {
              _index++;
            };
          if (_index<_length && _uniBuf[_index]=='\"')
            _index++;
          else
            {
              [GSWDeclarationFormatException 
                raise:GSWDFEMissingQuotedKeyPathEnd
                format:@"In %@ %@:No end '\"' for keyPath starting at line %d",
                _frameworkName,_fileName,
                [self lineIndexFromIndex:startIndex]];
            };
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          break;
        case '.':
          if (_index==startIndex)
            {
              [GSWDeclarationFormatException 
                raise:GSWDFEWrongKeyPathFormat
                format:@"In %@ %@: keyPath can't begin with '.' line %d",
                _frameworkName,_fileName,
                [self lineIndexFromIndex:startIndex]];
            }
          else
            _index++;
          break;
        default:
          if (_parserIsIdentifierChar(_uniBuf[_index]))
            _index++;
          else
            end=YES;
          break;
        };
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  if ((index-startIndex)==0)
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEEmptyKeyPath
        format:@"In %@ %@: Empty keyPath  at line %d",
        _frameworkName,_fileName,
        [self lineIndexFromIndex:startIndex]];
    }
  else
    {
      keyPath=[NSString stringWithCharacters:_uniBuf+startIndex
                        length:_index-startIndex];
    };
  NSDebugMLog(@"keyPath=%@",keyPath);
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return keyPath;
};

//--------------------------------------------------------------------
/** Try to Parse a boolean (Y/N/YES/NO/T/F/TRUE/FALSE value.
Index should be on the value first character.
Returns an NSNumber.
**/
- (NSNumber *)tryParseBoolean
{
  id value = nil;
  NSAssert(_index<_length, @"Reached buffer end parsing boolean");

  //ParserDebugLogBuffer(_uniBuf, _length, _index, 20);

  // Test if it is Y/YES or N/NO
  if (uni_toupper(_uniBuf[_index]) == 'Y' 
      || uni_toupper(_uniBuf[_index]) == 'T'
      || uni_toupper(_uniBuf[_index]) == 'N'
      || uni_toupper(_uniBuf[_index]) == 'F')
    {
      int i = (_index)+1;
      while(i < _length
            && _parserIsIdentifierChar(_uniBuf[i]))
	{
	  i++;
	}

      switch(i-_index)
        {
	  case 1:
	    {
	      if (uni_toupper(_uniBuf[(_index)]) == 'Y'
		  || uni_toupper(_uniBuf[(_index)]) == 'T')
		{
		  value = GSWNumberYes;
		  _index++;
		}
	      else if (uni_toupper(_uniBuf[(_index)]) == 'N'
		       || uni_toupper(_uniBuf[(_index)]) == 'F')
		{
		  value = GSWNumberNo;
		  _index++;
		}
	      break;
	    }
	  case 2:
	    {
	      if (uni_toupper(_uniBuf[(_index)]) == 'N'
		  && uni_toupper(_uniBuf[(_index)+1]) == 'O')
		{
		  value = GSWNumberNo;
		  _index += 2;
		}
	      break;
	    }
	  case 3:
	    {
	      if (uni_toupper(_uniBuf[(_index)]) == 'Y'
		  && uni_toupper(_uniBuf[(_index)+1]) == 'E'
		  && uni_toupper(_uniBuf[(_index)+2]) == 'S')
		{
		  value = GSWNumberYes;
		  _index += 3;
		}
	      break;
	    }
	  case 4:
	    {
	      if (uni_toupper(_uniBuf[(_index)]) == 'T'
		  && uni_toupper(_uniBuf[(_index)+1]) == 'R'
		  && uni_toupper(_uniBuf[(_index)+2]) == 'U'
		  && uni_toupper(_uniBuf[(_index)+3]) == 'E')
		{
		  value = GSWNumberYes;
		  _index += 4;
		}
	      break;
	    }
	  case 5:
	    {
	      if (uni_toupper(_uniBuf[(_index)]) == 'F'
		  && uni_toupper(_uniBuf[(_index)+1]) == 'A'
		  && uni_toupper(_uniBuf[(_index)+2]) == 'L'
		  && uni_toupper(_uniBuf[(_index)+3]) == 'S'
		  && uni_toupper(_uniBuf[(_index)+4]) == 'E')
		{
		  value = GSWNumberNo;
		  _index += 5;
		}
	      break;
	    }
        }
    }
  NSDebugMLog(@"value=%@",value);
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);  
  return value;
};

//--------------------------------------------------------------------
/** Parse a number
Index should be on the value first character
Returns a NSNumber
**/
-(NSNumber*)parseNumber
{
  NSNumber* value=nil;
  NSString* string=nil;
  int startIndex=_index;
  BOOL seenDot=NO;
  BOOL end=NO;
  NSAssert(_index<_length,@"Reached buffer end parsing number");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  if (_uniBuf[_index]=='-'
      || _uniBuf[_index]=='+')
    {
      _index++;
      if (_index>=_length)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEWrongNumberFormat
            format:@"In %@ %@: Bad number line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
    };
  while(!end && _index<_length)
    {
      if (_parserIsDigit(_uniBuf[_index]))
        _index++;
      else if (_uniBuf[_index]=='.')
        {
          if (seenDot)
            {
              [GSWDeclarationFormatException 
                raise:GSWDFEWrongNumberFormat
                format:@"In %@ %@: 2 dots in a number line %d",
                _frameworkName,_fileName,
                [self lineIndexFromIndex:startIndex]];
            }
          else
            {
              _index++;              
              seenDot=YES;
            };
        }
      else
        end=YES;
    };
  string=[NSString stringWithCharacters:_uniBuf+startIndex
                   length:_index-startIndex];
  NSDebugMLog(@"string=%@",string);
  if (seenDot)
    value=[NSNumber numberWithDouble:[string floatValue]];
  else
    value=GSWIntNumber([string intValue]);
  NSDebugMLog(@"value=%@",value);
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);  
  return value;
};

//--------------------------------------------------------------------
/** Parse a number
Index should be on the value first character ('#')
Returns a NSNumber
**/
-(NSNumber*)parseHexNumber
{
  NSNumber* value=nil;
  int startIndex=_index;
  NSAssert(_index<_length,@"Reached buffer end parsing number");
  NSAssert1(_uniBuf[_index]=='#',@"First character should be '#' not '%c'",(char)_uniBuf[_index]);

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  _index++; // skip '#'
  
  while(_index<_length
        && _parserIsHexDigit(_uniBuf[_index]))
    _index++;

  if (_index>startIndex+1)
    {
      NSString* string=nil;
      const char* cString=NULL;
      char* endPtr=NULL;
      int intValue=0;
      string=[NSString stringWithCharacters:_uniBuf+startIndex+1
                       length:_index-startIndex-1];
      NSDebugMLog(@"string=%@",string);
      cString=[string cString];
      intValue=strtol(cString,&endPtr,16);
      NSDebugMLog(@"cString='%s' endPtr='%s'",cString,endPtr);
      if (endPtr && *endPtr)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEWrongHexNumberFormat
            format:@"In %@ %@: Bad hex number line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
      value=GSWIntNumber(intValue);
    };
  NSDebugMLog(@"value=%@",value);
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);  
  return value;
};


//--------------------------------------------------------------------
/** Parse a value.
Index should be on the value first character
Returns a NSString
**/
-(id)parseValueAsAssociation:(BOOL)asAssociation
{
  id value=nil;
  NSAssert(_index<_length,@"Reached buffer end parsing an identifier");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  switch(_uniBuf[_index])
    {
    case '"': // a quoted string
      value=parseQuotedString(self);
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '<': // a data coded as hex
      value=parseHexData(self);
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '{': // a dictionary
      value=parseDictionaryWithValuesAsAssociations(self,NO);
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '(': // an array
      value=parseArray(self);
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '#':
      value=parseHexNumber(self);
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    default:
      value=tryParseBoolean(self);
      if (value)
        {
          if (asAssociation)
            value=[GSWAssociation associationWithValue:value];
        }
      else
        {
          // Number ?
          if (_parserIsDigit(_uniBuf[_index])
              || _uniBuf[_index]=='-'
              || _uniBuf[_index]=='+')
            {
              value=parseNumber(self);
              if (value && asAssociation)
                value=[GSWAssociation associationWithValue:value];
            }
          else
            {
              value=parseKeyPath(self);
              if (value && asAssociation)
                value=[GSWAssociation associationWithKeyPath:value];
            };
        };
    };
  NSDebugMLog(@"value (class=%@)=%@",[value class],value);
  NSDebugMLog(@"value (class=%@)=%@",[value class],value);
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return value;
}

//--------------------------------------------------------------------
/** Parse a dictionary.
Index should be on the value first character ('{')
Returns a NSString
**/
-(NSDictionary*)parseDictionaryWithValuesAsAssociations:(BOOL)valuesAsAssociations
{
  NSMutableDictionary* dictionary=[NSMutableDictionary dictionary];
  BOOL end=NO;
  int startIndex=_index;

  NSAssert(_index<_length,@"Reached buffer end parsing an dictionary");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  NSAssert1(_uniBuf[_index]=='{',@"Dictionary first character is not a '{' but a %c",(char)_uniBuf[_index]);

  _index++; // skip '{'
  while(!end && _index<_length)
    {
      int keyStartIndex=_index;
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      
      // Parse Key
      skipBlanksAndComments(self);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

      if (_index<_length)
        {
          if (_uniBuf[_index]=='}')
            {
              _index++;
              end=YES;
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
            }
          else
            {
              NSString* key=nil;
              key=parseKeyPath(self);

              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              skipBlanksAndComments(self);

              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              if (_index>=_length)
                {
                  [GSWDeclarationFormatException 
                    raise:GSWDFEUnexpectedBufferEnd
                    format:@"In %@ %@: Reached buffer end while trying to parse value of a dictionary entry",
                    _frameworkName,_fileName,
                    [self lineIndexFromIndex:keyStartIndex]];
                }
              else if (_uniBuf[_index]=='=')
                {
                  _index++;

                  skipBlanksAndComments(self);
                  //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);

                  if (_index>=_length)
                    {
                      [GSWDeclarationFormatException 
                        raise:GSWDFEUnexpectedBufferEnd
                        format:@"In %@ %@: Reached buffer end while trying to parse value of a dictionary entry",
                        _frameworkName,_fileName,
                        [self lineIndexFromIndex:keyStartIndex]];
                    }
                  else
                    {
                      id value=nil;
                      value=parseValueAsAssociation(self,valuesAsAssociations);
                      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
                      
                      if (value)
                        [dictionary setObject:value
                                    forKey:key];
                      else
                        {
                          [GSWDeclarationFormatException 
                            raise:GSWDFEMissingValue
                                       format:@"In %@ %@: No value for key '%@' at line %d",
                                       _frameworkName,_fileName,
                                       key,[self lineIndexFromIndex:keyStartIndex]];
                        };
                      
                      skipBlanksAndComments(self);
                      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
                      if (_index>=_length)
                        {
                          [GSWDeclarationFormatException 
                            raise:GSWDFEUnexpectedBufferEnd
                            format:@"In %@ %@: Reached buffer end while parse dictionary starting at %d",
                            _frameworkName,_fileName,
                            [self lineIndexFromIndex:keyStartIndex]];
                        }
                      else if (_uniBuf[_index]==';')
                        {
                          _index++;
                        };
                    };
                }
              else
                {
                  [GSWDeclarationFormatException 
                    raise:GSWDFEMissingSeparator
                    format:@"In %@ %@: No '=' sign when parsing dictionary entry (key = '%@') at line %d but '%c'",
                    _frameworkName,_fileName,
                    key,[self lineIndexFromIndex:keyStartIndex],(char)_uniBuf[_index]];
                };
            };
        }
      else
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEUnexpectedBufferEnd
            format:@"In %@ %@: Reached buffer end while trying to parse dictionary started at line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
      if (_index==startIndex)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEDictionaryParsingError
            format:@"In %@ %@: Found nothing  when parsing dictionary  at line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
    }
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return dictionary;
}

//--------------------------------------------------------------------
/** Parse an array.
Index should be on the value first character ('(')
Returns a NSString
**/
-(NSArray*)parseArray
{
  NSMutableArray* array=[NSMutableArray array];
  BOOL end=NO;
  int startIndex=_index;

  NSAssert(_index<_length,@"Reached buffer end parsing an array");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  NSAssert1(_uniBuf[_index]=='(',@"Array first character is not a '(' but a '%c'",(char)_uniBuf[_index]);

  _index++; // skip '('
  while(!end && _index<_length)
    {
      int valueStartIndex=_index;
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      
      // Parse Value
      skipBlanksAndComments(self);
      if (_index<_length)
        {
          if (_uniBuf[_index]==')')
            {
              _index++;
              end=YES;
              //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
            }
          else
            {
              id value=parseValueAsAssociation(self,NO);
              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              
              if (value)
                [array addObject:value];
              else
                {
                  [GSWDeclarationFormatException 
                    raise:GSWDFEMissingValue
                    format:@"IN %@ %@: No value at line %d",
                    _frameworkName,_fileName,
                    [self lineIndexFromIndex:valueStartIndex]];
                };
              
              skipBlanksAndComments(self);
              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              if (_index>=_length)
                {
                  [GSWDeclarationFormatException 
                    raise:GSWDFEUnexpectedBufferEnd
                    format:@"In %@ %@: Reached buffer end parsing array line %d",
                    _frameworkName,_fileName,
                    [self lineIndexFromIndex:startIndex]];
                }
              else if (_uniBuf[_index]==',')
                {
                  NSDebugMLog(@"Found ','");
                  _index++;
                }
              else
                {
                  [GSWDeclarationFormatException 
                    raise:GSWDFEUnexpectedCharacter
                    format:@"In %@ %@: Bad character '%c' parsing array line %d",
                    _frameworkName,_fileName,
                    (char)_uniBuf[_index],[self lineIndexFromIndex:startIndex]];
                };
            }
        }
      else
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEUnexpectedBufferEnd
            format:@"In %@ %@: Reached buffer end while trying to parse array started at line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
      
      if (_index==valueStartIndex)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEArrayParsingError
            format:@"In %@ %@: Found nothing when parsing array at line %d",
            _frameworkName,_fileName,
            [self lineIndexFromIndex:startIndex]];
        };
    }
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return array;
}

//--------------------------------------------------------------------
/** Parse a declaration.
Index should be on the identifier first character
Returns a GSWDeclaration.
**/
-(GSWDeclaration*)parseDeclaration
{
  GSWDeclaration* declaration=nil;
  NSString* identifier=nil;

  NSAssert(_index<_length,@"Reached buffer end parsing a declaration");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  identifier=parseIdentifier(self);

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  skipBlanksAndComments(self);

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  if (_index>=_length)
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEUnexpectedBufferEnd
        format:@"In %@ %@: End of buffer before getting declaration type for '%@' line %d",
        _frameworkName,_fileName,
        identifier,[self currentLineIndex]];
    }
  else if (_uniBuf[_index]==':')
    {
      NSString* type=nil;
      NSDictionary* associations=nil;
      _index++;
      skipBlanksAndComments(self);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      type=parseIdentifier(self);
      skipBlanksAndComments(self);
      if (_index>=_length)
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEUnexpectedBufferEnd
                       format:@"In %@ %@: End of buffer before getting declaration bindings for '%@' (type '%@') line %d",
                       _frameworkName,_fileName,
                       identifier,type,[self currentLineIndex]];
        }
      else if (_uniBuf[_index]=='{')
        {
          associations=parseDictionaryWithValuesAsAssociations(self,YES);
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          skipBlanksAndComments(self);
          if (_index<_length)
            {
              if (_uniBuf[_index]==';')
                {
                  _index++;
                };
            };
          //else no bindings dictionary
          declaration=[GSWDeclaration declarationWithName:identifier
                                      type:type
                                      associations:associations];
        }
      else
        [GSWDeclarationFormatException 
          raise:GSWDFEUnexpectedCharacter
          format:@"In %@ %@: Don't know what do do with '%c' line %d.",
          _frameworkName,_fileName,
          (char)_uniBuf[_index],[self currentLineIndex]];
    }
  else if (_uniBuf[_index]=='=') // Alias like Identifier1=Identifier2;
    {
      NSString* aliasedIdentifier=nil;
      GSWDeclaration* aliasedDeclaration=nil;
      _index++;
      skipBlanksAndComments(self);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      aliasedIdentifier=parseIdentifier(self);
      skipBlanksAndComments(self);
      if (_index<_length)
        {
          if (_uniBuf[_index]==';')
            {
              _index++;
            };
        };
      NSDebugMLog(@"aliasedIdentifier=%@",aliasedIdentifier);
      aliasedDeclaration=[_declarations objectForKey:aliasedIdentifier];
      if (aliasedDeclaration)
        {
          declaration=[GSWDeclaration declarationWithName:identifier
                                      type:[aliasedDeclaration type]
                                      associations:[aliasedDeclaration associations]];
        }
      else
        {
          [GSWDeclarationFormatException 
            raise:GSWDFEMissingAliasedDeclaration
            format:@"In %@ %@: Can't find declaration named '%@' to be aliased as '%@'. line %d.",
            _frameworkName,_fileName,
            aliasedIdentifier,identifier,
            [self currentLineIndex]];
        };
    }
  else
    {
      [GSWDeclarationFormatException 
        raise:GSWDFEMissingSeparator
        format:@"In %@ %@: No ':' delimiter while parsing declaration for '%@' line %d. Found '%c'",
        _frameworkName,_fileName,
        identifier,[self currentLineIndex],(char)_uniBuf[_index]];
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return declaration;
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

