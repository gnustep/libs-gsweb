/** GSWBaseParser - <title>GSWeb: Class GSWBaseParser</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
   $Revision$
   $Date$

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

// $Id$

#ifndef _GSWBaseParser_h__
	#define _GSWBaseParser_h__


//====================================================================
@interface GSWBaseParser : NSObject
{
  NSString* _string;
  unichar* _uniBuf;
  int _length;
  int _index;
}
-(NSString*)currentLineAndColumnIndexesString;
-(NSString*)lineAndColumnIndexesStringFromIndex:(int)index;
-(int)currentLineIndex;
-(int)lineIndexFromIndex:(int)index;
-(void)lineAndColumnIndexesFromIndex:(int)index
                    returnsLineIndex:(int*)lineIndexPtr
                         columnIndex:(int*)colIndexPtr;
@end

void
_ParserDebugLogBuffer(char* fn, char* file, int line, unichar* uniBuf,
		      int length, int index, int charsCount);
#define ParserDebugLogBuffer(uniBuf,length,index,charsCount) \
	_ParserDebugLogBuffer(__PRETTY_FUNCTION__,	\
	__FILE__, __LINE__, uniBuf, length, index, charsCount)

static inline BOOL _parserIsDigit(unichar c)
{
  return ((c>='0' && c<='9') ? YES: NO);
};

static inline BOOL _parserIsHexDigit(unichar c)
{
  return (((c>='0' && c<='9')
           || (c>='A' && c<='F')
           || (c>='a' && c<='f')) ? YES: NO);
};

static inline BOOL _parserIsBlankChar(unichar c)
{
  switch(c)
    {
      case ' ':
    case '\t':
    case '\f':
    case '\r':
    case '\n':
    case '\v':
      return YES;
    default:
      return NO;
    };
};

static inline BOOL _parserIsEndOfLineChar(unichar c)
{
  switch(c)
    {
    case '\r':
    case '\n':
      return YES;
    default:
      return NO;
    };
};


#endif // _GSWBaseParser_h__
