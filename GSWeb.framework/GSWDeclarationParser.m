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


//====================================================================
@implementation GSWDeclarationParser

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
-(void)dealloc
{
  DESTROY(_pragmaDelegate);
  DESTROY(_declarations);
  DESTROY(_fileName);
  DESTROY(_frameworkName);

  [super dealloc];
};

-(NSDictionary*)parseDeclarationString:(NSString*)declarationString
                                 named:(NSString*)declarationFileName
                      inFrameworkNamed:(NSString*)declarationFrameworkName
{
  LOGObjectFnStart();

  if (_declarations)
    [_declarations removeAllObjects];
  else
    _declarations=(NSMutableDictionary*)[NSMutableDictionary new];

  ASSIGN(_string,declarationString);
  ASSIGN(_fileName,declarationFileName);
  ASSIGN(_frameworkName,declarationFrameworkName);

  NSDebugMLog(@"declarationString=%@",declarationString);
  _length=[_string length];

  _uniBuf =  (unichar*)objc_malloc(sizeof(unichar)*(_length+1));
  NS_DURING
    {
      [_string getCharacters:_uniBuf];
      
      NSDebugMLog(@"index=%d length=%d",index,_length);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);

      while(_index<_length)
        {      
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          [self skipBlanksAndComments];
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          if (_index<_length)
            {
              if (_uniBuf[_index]=='#')
                {
                  [self parsePragma];
                  NSDebugMLog(@"index=%d _length=%d",_index,20);
                }
              else if (_parserIsIdentifierChar(_uniBuf[_index]))
                {
                  GSWDeclaration* declaration=[self parseDeclaration];
                  NSDebugMLog(@"declaration=%@",declaration);
                  [_declarations setObject:declaration
                                 forKey:[declaration name]];
                  NSDebugMLog(@"index=%d _length=%d",_index,20);
                }
              else
                {
                  [NSException raise:NSInvalidArgumentException 
                               format:@"No identifier %@",
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

  LOGObjectFnStop();

  return _declarations;
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
      isLastSkipped=[self skipBlanks];
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      if ([self skipComment])
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
          [NSException raise:NSInvalidArgumentException 
                       format:@"No pragma delegate for pragma directive '%@'"];
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
      [NSException raise:NSInvalidArgumentException 
                   format:@"unknown pragma directive '%@' at line %@",
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
      [NSException raise:NSInvalidArgumentException 
                   format:@"No identifier %@",
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
  return [self parseIdentifier];
}

//--------------------------------------------------------------------
/** Parse a quoted string.
Index should be on the value first character (")
Returns a NSString without '"' pefix and suffix
**/
-(id)parseQuotedString
{
  NSString* string=nil;
  int startIndex=_index;
  NSAssert(_index<_length,@"Reached buffer end parsing an quoted string");
  NSAssert(_uniBuf[_index]=='"',@"First character should be '\"'");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  _index++; // skip '"'
  while(_index<_length
        && _uniBuf[_index]!='"')
    {
      _index++;
    };
  if (_index<_length && _uniBuf[_index]=='"')
    _index++;
  else
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No end '\"' for quoted string starting at line %d",
                   [self lineIndexFromIndex:startIndex]];
    };  
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  string=[NSString stringWithCharacters:_uniBuf+startIndex+1
                   length:_index-startIndex-2]; // don't take '"' prefix and suffix
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
      [NSException raise:NSInvalidArgumentException 
                   format:@"No end '>' for data starting at line %d",
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
              [NSException raise:NSInvalidArgumentException 
                           format:@"No end '\'' for keyPath starting at line %d",
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
              [NSException raise:NSInvalidArgumentException 
                           format:@"No end '\"' for keyPath starting at line %d",
                           [self lineIndexFromIndex:startIndex]];
            };
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          break;
        case '.':
          if (_index==startIndex)
            {
              [NSException raise:NSInvalidArgumentException 
                           format:@"keyPath can't begin with '.' line %d",
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
      [NSException raise:NSInvalidArgumentException 
                   format:@"Empty keyPath  at line %d",
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
/** Try to Parse a boolean (Y/N/YES/NO value
Index should be on the value first character
Returns a NSString
**/
-(NSNumber*)tryParseBoolean
{
  id value=nil;
  NSAssert(_index<_length,@"Reached buffer end parsing boolean");

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

  // Test if it is Y/YES or N/NO
  if (_uniBuf[_index]=='Y' || _uniBuf[_index]=='N')
    {
      int i=(_index)+1;
      while(i<_length
            && _parserIsIdentifierChar(_uniBuf[i]))
        i++;
      switch(i-_index)
        {
        case 1:
          if (_uniBuf[(_index)]=='Y')
            {
              value=[NSNumber numberWithBool:YES];
              _index++;
            }
          else if (_uniBuf[(_index)]=='N')
            {
              value=[NSNumber numberWithBool:NO];
              _index++;
            };
          break;
        case 2:
          if (_uniBuf[(_index)+1]=='O')
            {
              value=[NSNumber numberWithBool:NO];
              _index+=2;
            };
          break;
        case 3:
          if (_uniBuf[(_index)+1]=='E'
              && _uniBuf[(_index)+2]=='S')
            {
              value=[NSNumber numberWithBool:YES];
              _index+=3;
            };
          break;
        };
    };
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
          [NSException raise:NSInvalidArgumentException 
                       format:@"Bad number line %d",
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
              [NSException raise:NSInvalidArgumentException 
                           format:@"2 dots in a number line %d",
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
    value=[NSNumber numberWithInt:[string intValue]];
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
          [NSException raise:NSInvalidArgumentException 
                       format:@"Bad hex number line %d",
                       [self lineIndexFromIndex:startIndex]];
        };
      value=[NSNumber numberWithInt:intValue];
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
      value=[self parseQuotedString];
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '<': // a data coded as hex
      value=[self parseHexData];
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '{': // a dictionary
      value=[self parseDictionaryWithValuesAsAssociations:NO];
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '(': // an array
      value=[self parseArray];
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    case '#':
      value=[self parseHexNumber];
      if (value && asAssociation)
        value=[GSWAssociation associationWithValue:value];
      break;
    default:
      value=[self tryParseBoolean];
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
              value=[self parseNumber];
              if (value && asAssociation)
                value=[GSWAssociation associationWithValue:value];
            }
          else
            {
              value=[self parseKeyPath];
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
      [self skipBlanksAndComments];
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
              key=[self parseKey];

              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              [self skipBlanksAndComments];

              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              if (_index>=_length)
                {
                  [NSException raise:NSInvalidArgumentException 
                               format:@"Reached buffer end while trying to parse value of a dictionary entry",
                               [self lineIndexFromIndex:keyStartIndex]];
                }
              else if (_uniBuf[_index]=='=')
                {
                  _index++;

                  [self skipBlanksAndComments];
                  //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);

                  if (_index>=_length)
                    {
                      [NSException raise:NSInvalidArgumentException 
                                   format:@"Reached buffer end while trying to parse value of a dictionary entry",
                                   [self lineIndexFromIndex:keyStartIndex]];
                    }
                  else
                    {
                      id value=nil;
                      value=[self parseValueAsAssociation:valuesAsAssociations];
                      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
                      
                      if (value)
                        [dictionary setObject:value
                                    forKey:key];
                      else
                        {
                          [NSException raise:NSInvalidArgumentException 
                                       format:@"No value for key '%@' at line %d",
                                       key,[self lineIndexFromIndex:keyStartIndex]];
                        };
                      
                      [self skipBlanksAndComments];
                      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
                      if (_index>=_length)
                        {
                          [NSException raise:NSInvalidArgumentException 
                                       format:@"Reached buffer end while parse dictionary starting at %d",
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
                  [NSException raise:NSInvalidArgumentException 
                               format:@"No '=' sign when parsing dictionary entry (key = '%@') at line %d but '%c'",
                               key,[self lineIndexFromIndex:keyStartIndex],(char)_uniBuf[_index]];
                };
            };
        }
      else
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"Reached buffer end while trying to parse dictionary started at line %d",
                       [self lineIndexFromIndex:startIndex]];
        };
      if (_index==startIndex)
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"Found nothing  when parsing dictionary  at line %d",
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
      [self skipBlanksAndComments];
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
              id value=[self parseValueAsAssociation:NO];
              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              
              if (value)
                [array addObject:value];
              else
                {
                  [NSException raise:NSInvalidArgumentException 
                               format:@"No value at line %d",
                               [self lineIndexFromIndex:valueStartIndex]];
                };
              
              [self skipBlanksAndComments];
              //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);
              if (_index>=_length)
                {
                  [NSException raise:NSInvalidArgumentException 
                               format:@"Reached buffer end parsing array line %d",
                               [self lineIndexFromIndex:startIndex]];
                }
              else if (_uniBuf[_index]==',')
                {
                  NSDebugMLog(@"Found ','");
                  _index++;
                }
              else
                {
                  [NSException raise:NSInvalidArgumentException 
                               format:@"Bad character '%c' parsing array line %d",
                               (char)_uniBuf[_index],[self lineIndexFromIndex:startIndex]];
                };
            }
        }
      else
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"Reached buffer end while trying to parse array started at line %d",
                       [self lineIndexFromIndex:startIndex]];
        };
      
      if (_index==valueStartIndex)
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"Found nothing  when parsing array  at line %d",
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
  identifier=[self parseIdentifier];

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  [self skipBlanksAndComments];

  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  if (_index>=_length)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"End of buffer before getting declaration type for '%@' line %d",
                   identifier,[self currentLineIndex]];
    }
  else if (_uniBuf[_index]==':')
    {
      NSString* type=nil;
      NSDictionary* associations=nil;
      _index++;
      [self skipBlanksAndComments];
      //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
      type=[self parseIdentifier];
      [self skipBlanksAndComments];
      if (_index>=_length)
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"End of buffer before getting declaration bindings for '%@' (type '%@') line %d",
                       identifier,type,[self currentLineIndex]];
        }
      else if (_uniBuf[_index]=='{')
        {
          associations=[self parseDictionaryWithValuesAsAssociations:YES];
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          [self skipBlanksAndComments];
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
        [NSException raise:NSInvalidArgumentException 
                     format:@"don't know whet do do with '%c' line %d.",
                     (char)_uniBuf[_index],[self currentLineIndex]];
    }
  else
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No ':' delimiter while parsing declaration for '%@' line %d. Found '%c'",
                   identifier,[self currentLineIndex],(char)_uniBuf[_index]];
    };
  //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
  return declaration;
};

@end

