/** GSWHTMLRawParser.m - <title>GSWeb: Class GSWHTMLRawParser</title>

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

#include "GSWHTMLRawParser.h"

//strlen("gsweb")
#define GSWEB_TAG_LENGTH 5   
//strlen("webobject")
#define WO_TAG_LENGTH 9
//strlen("!--")
#define COMMENT_TAG_LENGTH 3

static GSWHTMLRawParserTagType GetTagType(unichar* uniBuf,int length,int* indexPtr,BOOL* isClosingTagPtr)
{
  GSWHTMLRawParserTagType tagType=GSWHTMLRawParserTagType_unknown;
  NSCAssert(*indexPtr<length,@"End of buffer");
  if (uniBuf[(*indexPtr)]=='/')
    {
      *isClosingTagPtr=YES;
      (*indexPtr)++;
    }
  else
    *isClosingTagPtr=NO;
  if (*indexPtr>=length)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"End of buffer reached while geting tag type"];
    };
  switch(uniBuf[(*indexPtr)])
    {
    case 'g':
    case 'G':
      if ((*indexPtr)+GSWEB_TAG_LENGTH<length
          && tolower(uniBuf[(*indexPtr)+1])=='s'
          && tolower(uniBuf[(*indexPtr)+2])=='w'
          && tolower(uniBuf[(*indexPtr)+3])=='e'
          && tolower(uniBuf[(*indexPtr)+4])=='b')
        {
          (*indexPtr)+=GSWEB_TAG_LENGTH;
          tagType=GSWHTMLRawParserTagType_gsweb;
        }
      break;
    case 'w':
    case 'W':
      if ((*indexPtr)+WO_TAG_LENGTH<length
          && tolower(uniBuf[(*indexPtr)+1])=='e'
          && tolower(uniBuf[(*indexPtr)+2])=='b'
          && tolower(uniBuf[(*indexPtr)+3])=='o'
          && tolower(uniBuf[(*indexPtr)+4])=='b'
          && tolower(uniBuf[(*indexPtr)+5])=='j'
          && tolower(uniBuf[(*indexPtr)+6])=='e'
          && tolower(uniBuf[(*indexPtr)+7])=='c'
          && tolower(uniBuf[(*indexPtr)+8])=='t')
        {
          (*indexPtr)+=WO_TAG_LENGTH;
          tagType=GSWHTMLRawParserTagType_wo;
        };
      break;
    case '#':
      (*indexPtr)+=1;
      tagType=GSWHTMLRawParserTagType_oog;
      break;
    case '!':
      if ((*indexPtr)+COMMENT_TAG_LENGTH<length
          && tolower(uniBuf[(*indexPtr)+1])=='-'
          && tolower(uniBuf[(*indexPtr)+2])=='-')
        {
          (*indexPtr)+=COMMENT_TAG_LENGTH;
          tagType=GSWHTMLRawParserTagType_comment;
        };
      break;
    default:
      tagType=GSWHTMLRawParserTagType_unknown;
      break;
    };
  return tagType;
};
      

//====================================================================
@implementation GSWHTMLRawParser

//--------------------------------------------------------------------
+(GSWHTMLRawParser*)parserWithDelegate:(id<GSWTemplateParserDelegate>)delegate
                            htmlString:(NSString*)htmlString
{
  return [[[self alloc]initWithDelegate:delegate
                       htmlString:htmlString]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithDelegate:(id<GSWTemplateParserDelegate>)delegate
           htmlString:(NSString*)htmlString
{
  if ((self=[self init]))
    {
      ASSIGN(_delegate,delegate);
      ASSIGNCOPY(_string,htmlString);
    };
  return self;
}

//--------------------------------------------------------------------
/** Called when finding a new dynamic tag or a new comment or at the 
end of the string to record seen text parts
Call delegate -parser:didParseText:
**/
-(void)didParseText
{
  LOGObjectFnStart();

  // Is there some text ?
  if(_textStopIndex>=_textStartIndex)
    {
      // Create text string
      NSString* content=[NSString stringWithCharacters:_uniBuf+_textStartIndex
                                  length:_textStopIndex-_textStartIndex+1];

      NSDebugMLLog(@"GSWHTMLRawParser",@"GSWHTMLRawParser didParseText (length=%d): %@",
                   [content length],content);                   

      // Call delegate -parser:didParseText:
      [_delegate  parser:self
                  didParseText:content];

      // reset textStartIndex
      _textStartIndex=_index;
    };

  LOGObjectFnStop();
}


//--------------------------------------------------------------------
/** Called when a new dynamic tag is opened 
tagType can be gsweb, wo or oog
taProperties contains key+values of tag properties
Call delegate -parser:didParseOpeningDynamicTagOfType:withProperties:
**/
-(void)startDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
              withProperties:(NSDictionary*)tagProperties
                templateInfo:(NSString*)templateInfo
{
  LOGObjectFnStart();

  // Records previously parsed text
  [self didParseText];

  NSDebugMLLog(@"GSWHTMLRawParser",@"GSWHTMLRawParser startDynamicTagOfType:%d withProperties:%@",
               tagType,tagProperties);

  // Calls delegate -parser:didParseOpeningDynamicTagOfType:withProperties:
  [_delegate  parser:self
              didParseOpeningDynamicTagOfType:tagType
              withProperties:tagProperties
              templateInfo:templateInfo];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
/** Called when a dynamic tag is closed
tagType can be gsweb, wo or oog
Call delegate -parser:didParseClosingDynamicTagOfType:
**/
-(void)stopDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
           withTemplateInfo:(NSString*)templateInfo
{
  LOGObjectFnStart();

  // Records previously parsed text
  [self didParseText];

  NSDebugMLLog(@"GSWHTMLRawParser",@"GSWHTMLRawParser stopDynamicTagOfType:%d",
               tagType);

  // Calls delegate -parser:didParseClosingDynamicTagOfType:
  [_delegate  parser:self
              didParseClosingDynamicTagOfType:tagType
              withTemplateInfo:templateInfo];

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
/** Called when a is parsed
Call delegate -parser:didParseComment:
**/
-(void)didParseCommentWithContentString:(NSString*)contentString
{
  LOGObjectFnStart();

  // Records previously parsed text
  [self didParseText];

  // Is there comment text
  if ([contentString length]>0)
    {
      NSDebugMLLog(@"GSWHTMLRawParser",@"GSWHTMLRawParser didParseComment (length=%d): %@",
                   [contentString length],contentString);                   

      // Calls delegate -parser:didParseComment:
      [_delegate parser:self
                 didParseComment:contentString];
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
/** Skip a quoted string
indexPtr should point on the first quote
stopIndex should be the end of the string
when returning indexPtr point on the last quote.
Quoted substrings are handled
An exception is raised if the end quote is not found,...
**/
-(void)_skipQuotedStringWithQuote:(unichar)quote
                            index:(int*)indexPtr
                         stopIndex:(int)stopIndex
{
  int startIndex=0;

  LOGObjectFnStart();
  
  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);

  NSAssert2(_uniBuf[*indexPtr]==quote,@"First character is not a '%c' but a '%c'",
            (char)quote,(char)_uniBuf[*indexPtr]);

  (*indexPtr)++; //skip quote

  startIndex=*indexPtr;

  while(*indexPtr<=stopIndex
        && _uniBuf[*indexPtr]!=quote)
    {
      if (_uniBuf[*indexPtr]=='"' || _uniBuf[*indexPtr]=='\'')        
        {
          [self _skipQuotedStringWithQuote:_uniBuf[*indexPtr]
                index:indexPtr
                stopIndex:stopIndex];
          (*indexPtr)++;// skip last quote
        }
      else
        (*indexPtr)++;
    }
  NSDebugMLog(@"startIndex=%d *indexPtr=%d _uniBuf[*indexPtr]='%c'",
              startIndex,*indexPtr,(char)_uniBuf[*indexPtr]);
  if (_uniBuf[*indexPtr]!=quote)
    {
      if (*indexPtr>stopIndex)
        [NSException raise:NSInvalidArgumentException 
                     format:@"Found end of string before end quote when "
                     @"skipping quoted string starting at %@.",
                     [self currentLineAndColumnIndexesString]];
      else
        [NSException raise:NSInvalidArgumentException 
                     format:@"Didn't found end quote when skipping quoted "
                     @"string starting at %@. Found '%c' instead",
                     [self currentLineAndColumnIndexesString],(char)_uniBuf[_index]];
    };


  NSAssert2(_uniBuf[*indexPtr]==quote,@"Last character is not a '%c' but a '%c'",
            (char)quote,(char)_uniBuf[*indexPtr]);

  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);
  NSDebugMLog(@"startIndex=%d *indexPtr=%d _uniBuf[*indexPtr]='%c'",
              startIndex,*indexPtr,(char)_uniBuf[*indexPtr]);

  LOGObjectFnStop();
}
  
//--------------------------------------------------------------------
/** parse and return the quoted string without quotes
indexPtr should point on the first quote
stopIndex should be the end of the string
when returning indexPtr point on the last quote.
Quoted substrings are handled
An exception is raised if the end quote is not found,...
**/
-(NSString*)_parseQuotedStringWithQuote:(unichar)quote
                                  index:(int*)indexPtr
                              stopIndex:(int)stopIndex
{
  NSString* string=nil;
  int startIndex=0;

  LOGObjectFnStart();

  NSAssert2(_uniBuf[*indexPtr]==quote,@"First character is not a '%c' but a '%c'",
            (char)quote,(char)_uniBuf[*indexPtr]);

  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);

  startIndex=(*indexPtr);

  [self _skipQuotedStringWithQuote:quote
        index:indexPtr
        stopIndex:stopIndex];

  NSAssert2(_uniBuf[*indexPtr]==quote,@"Last character is not a '%c' but a '%c'",
            (char)quote,(char)_uniBuf[*indexPtr]);

  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);
  NSDebugMLog(@"startIndex=%d *indexPtr=%d _uniBuf[*indexPtr]='%c'",
              startIndex,*indexPtr,(char)_uniBuf[*indexPtr]);
  string=[NSString stringWithCharacters:_uniBuf+startIndex+1 // +1: skip begining quote
                   length:*indexPtr-startIndex-1]; // -1 because -1 for begining quote, -1 for ending quote +1 for length

  NSDebugMLog(@"'string'='%@'",string);

  LOGObjectFnStop();

  return string;
}
  
//--------------------------------------------------------------------
/** parse and return a property string (either key or value), stoping when 
ending0 or ending1 charaters is found or when stop index is reached
indexPtr should point on the begining of the string or on blanks before it.
stopIndex should be the end of the string
when returning indexPtr point on the ending char or on the character after 
stopIndex if end of string is found

Quoted substrings are handled
An exception is raised if it find a problem (no end quote for quoted strings,...
It skip starting blank spaces
**/
-(NSString*)_parsePropertiesStringEndingWith:(unichar)ending0
                                          or:(unichar)ending1
                                       index:(int*)indexPtr
                                   stopIndex:(int)stopIndex  
{
  NSString* string=nil;
  int startIndex=0;
  LOGObjectFnStart();

  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);

  while(*indexPtr<=stopIndex
        && _uniBuf[*indexPtr]==' ')
    (*indexPtr)++;

  startIndex=*indexPtr;
  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,startIndex,stopIndex+1);

  if (*indexPtr<=stopIndex)
    {
      if (_uniBuf[*indexPtr]=='"'
          || _uniBuf[*indexPtr]=='\'')
        {
          //ParserDebugLogBuffer(_uniBuf,stopIndex+1,*indexPtr,stopIndex+1);
          string=[self _parseQuotedStringWithQuote:_uniBuf[*indexPtr]
                       index:indexPtr
                       stopIndex:stopIndex];          
          NSDebugMLog(@"indexPtr=%d 'string'='%@'",*indexPtr,string);
          (*indexPtr)++; // skip last quote
        }
      else
        {
          while(*indexPtr<=stopIndex
                && _uniBuf[*indexPtr]!=ending0
                && _uniBuf[*indexPtr]!=ending1)
            {
              if (_uniBuf[*indexPtr]=='"' || _uniBuf[*indexPtr]=='\'')
                {
                  [self _skipQuotedStringWithQuote:_uniBuf[*indexPtr]
                        index:indexPtr
                        stopIndex:stopIndex];
                  (*indexPtr)++;// skip last quote
                }
              else
                (*indexPtr)++;
            };
          NSDebugMLog(@"startIndex=%d stopIndex=%d *indexPtr=%d _uniBuf[*indexPtr]='%c'",
                      startIndex,stopIndex,*indexPtr,(char)_uniBuf[*indexPtr]);
          if (*indexPtr>startIndex)
            string=[NSString stringWithCharacters:_uniBuf+startIndex
                             length:*indexPtr-startIndex];
          NSDebugMLog(@"'string'='%@'",string);
        };
    };

  NSDebugMLog(@"'string'='%@'",string);                      

  LOGObjectFnStop();
  return string;
}
  
//--------------------------------------------------------------------
/** parse a tag properties
startIndex should point on the begining of the string
stopIndex should be the end of the string

Quoted strings are handled
An exception is raised if it find a problem (no end quote for quoted strings,...)

gsweb/wo case: start index and stopIndex must define a string that:
aa=bb c="ddd" name=element_name

OOG case:  the string is like that:
element_name aa=bb c="ddd" 
  (for OOg, startIndex should point on the Element Name. No exception is raised 
if it is not the case but you'll have problems later...)
**/
-(NSDictionary*)tagPropertiesForType:(GSWHTMLRawParserTagType)tagType
                        betweenIndex:(int)startIndex
                            andIndex:(int)stopIndex
{
  NSMutableDictionary* properties=nil;
  LOGObjectFnStart();
  //ParserDebugLogBuffer(_uniBuf,stopIndex+1,startIndex,stopIndex+1);
  if (stopIndex>=startIndex)
    {
      int index=startIndex;
      if (tagType==GSWHTMLRawParserTagType_oog)
        {
          NSString* tagName=nil;
          while(index<=stopIndex)
            {
              if (_uniBuf[index]==' ')
                {
                  if ((index-1)>startIndex)
                    {
                      tagName=[NSString stringWithCharacters:_uniBuf+startIndex
                                        length:index-startIndex+1];
                      NSDebugMLog(@"tagName=%@",tagName);                      
                    };
                  break;
                }
            };
          if (!tagName && index>stopIndex)
            {
              tagName=[NSString stringWithCharacters:_uniBuf+startIndex
                                length:index-startIndex];
              NSDebugMLog(@"tagName=%@",tagName);
            };
          if (tagName)
            {
              if (!properties)
                properties=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              [properties setObject:tagName
                          forKey:@"name"];
            };
        };
      // Skip blank
      while(index<=stopIndex
            && _uniBuf[index]==' ')
        index++;

      while(index<=stopIndex)
        {
          NSString* key=[self _parsePropertiesStringEndingWith:'='
                              or:' '
                              index:&index
                              stopIndex:stopIndex];
          NSDebugMLog(@"'key'='%@'",key);
          // Skip blank
          while(index<=stopIndex
                && _uniBuf[index]==' ')
            index++;

          if ([key length]>0)
            {
              key=[key lowercaseString];
              if (!properties)
                properties=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              if (index>stopIndex) // key without value
                [properties setObject:@""
                            forKey:key];
              else if (_uniBuf[index]=='=') // key=value
                {
		  NSString *value;
                  index++;
                  value=[self _parsePropertiesStringEndingWith:'='
			      or:' '
			      index:&index
			      stopIndex:stopIndex];
                  NSDebugMLog(@"'value'='%@'",value);
                  NSAssert(value,@"No value");
                  [properties setObject:value
                              forKey:key];
                }
              else // key without value
                [properties setObject:@""
                            forKey:key];                  
            };
        };
    };
  NSDebugMLog(@"properties=%@",properties);                      
  LOGObjectFnStop();
  return properties;
};

//--------------------------------------------------------------------
/** Parse the html _string and call delegate methods
May raise exception.
**/
-(void)parseHTML
{
//  Object obj = null;
  LOGObjectFnStart();
  NSDebugMLog(@"_string=%@",_string);
  _length=[_string length];

  _uniBuf =  (unichar*)objc_malloc(sizeof(unichar)*(_length+1));
  NS_DURING
    {
      [_string getCharacters:_uniBuf];

      _index=0;

      NSDebugMLog(@"index=%d length=%d",_index,_length);
      //ParserDebugLogBuffer(_uniBuf,_length,_index,_length);

      _textStartIndex=_index;
      while(_index<_length)
        {      
          //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
          switch(_uniBuf[_index])
            {
            case '<': // tagStart
              {
                int tagStartIndex=_index;

                //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

                // skip '<'
                _index++;
                
                //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
                if (_index>=_length)
                  {
                    [NSException raise:NSInvalidArgumentException 
                                 format:@"Reached end of string when parsing tag opening at  %@.",
                                 [self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                  }
                else
                  {
                    BOOL isClosingTag=NO;
                    GSWHTMLRawParserTagType tagType=GetTagType(_uniBuf,_length,&_index,&isClosingTag);
                    int tagPropertiesStartIndex=_index;
                    _textStopIndex=tagStartIndex-1;
                    NSDebugMLog(@"tagType=%d isClosingTag=%s _textStartIndex=%d",tagType,(isClosingTag ? "YES" : "NO"),_textStartIndex);
                    if (_parserIsDynamicTagType(tagType))
                      {
                        //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

                        // Find tag End;
                        while(_index<_length
                              && _uniBuf[_index]!='>')
                          _index++;

                        //ParserDebugLogBuffer(_uniBuf,_length,_index,20);

                        if (_uniBuf[_index]!='>')
                          {
                            [NSException raise:NSInvalidArgumentException 
                                         format:@"Reached end of string searching for tag end. Tag started at %@.",
                                         [self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                          }
                        else
                          {
                            BOOL stopTag=NO;
                            int tagStopIndex=_index;
                            int tagPropertiesStopIndex=_index;
                            NSDebugMLog(@"tagStartIndex=%d tagStopIndex=%d _textStartIndex=%d _textStopIndex=%d _length=%d _index=%d",
                                        tagStartIndex,tagStopIndex,_textStartIndex,_textStopIndex,_length,_index);
                            if (isClosingTag)
                              {
                                [self stopDynamicTagOfType:tagType
                                      withTemplateInfo:[self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                              }
                            else 
                              {
                                NSString* tagPropertiesString=nil;
				NSDictionary* tagProperties;

                                if (_uniBuf[_index-1]=='/')
                                  {
                                    stopTag=YES;
                                    tagPropertiesStopIndex--;
                                  };
                                NSDebugMLog(@"stopTag=%d",stopTag);
                                tagPropertiesString=[NSString stringWithCharacters:_uniBuf+tagPropertiesStartIndex
                                                              length:tagPropertiesStopIndex-tagPropertiesStartIndex];
                                NSDebugMLog(@"tagPropertiesString='%@'",tagPropertiesString);
                                tagProperties=[self tagPropertiesForType:tagType
                                                                  betweenIndex:tagPropertiesStartIndex
                                                                  andIndex:tagPropertiesStopIndex-1];
                                NSDebugMLog(@"tagProperties='%@'",tagProperties);
                                [self startDynamicTagOfType:tagType
                                      withProperties:tagProperties
                                      templateInfo:[self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                                if (stopTag)
                                  [self stopDynamicTagOfType:tagType
                                        withTemplateInfo:[self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                              }
                            //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
                            _index++;
                            //ParserDebugLogBuffer(_uniBuf,_length,_index,20);
                            _textStartIndex=_index;
                            NSDebugMLog(@"_textStartIndex=%d _textStopIndex=%d _length=%d _index=%d",
                                        _textStartIndex,_textStopIndex,_length,_index);
                          };
                      }
                    else if (_parserIsCommentTagType(tagType))
                      {
                        BOOL foundCommentEnd=NO;
                        // Find tag End;
                        while(!foundCommentEnd && _index<_length)
                          {
                            if (_uniBuf[_index]=='>'
                                &&_uniBuf[_index-1]=='-'
                                && _uniBuf[_index-2]=='-')
                              {
                                foundCommentEnd=YES;
                              }
                            else
                              _index++;
                          };
                        if (!foundCommentEnd)
                          {
                            [NSException raise:NSInvalidArgumentException 
                                         format:@"Reached end of string searching for comment end. Comment started at %@.",
                                         [self lineAndColumnIndexesStringFromIndex:tagStartIndex]];
                          }
                        else
                          {
                            NSString* commentString=[NSString stringWithCharacters:_uniBuf+tagPropertiesStartIndex
                                                              length:_index-tagPropertiesStartIndex-2]; //-2 for last --
                            [self didParseCommentWithContentString:commentString];
                            _index++;
                            _textStartIndex=_index;
                            NSDebugMLog(@"_textStartIndex=%d _textStopIndex=%d _length=%d _index=%d",
                                        _textStartIndex,_textStopIndex,_length,_index);
                          };
                      };
                  };
              };
              break;
            case '\\':// escape
              _index++;
              break;
            default:
              _index++;
              break;
            };
        };
      _textStopIndex=_length-1;
      [self didParseText];
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
  LOGObjectFnStop();
};


@end

