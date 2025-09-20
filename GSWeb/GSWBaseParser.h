/* GSWBaseParser.h - <title>GSWeb: Class GSWBaseParser</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999

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

/**
 * Base parser class providing fundamental parsing functionality for GSWeb
 * template and declaration parsers. This abstract class encapsulates common
 * parsing operations including string buffer management, position tracking,
 * and line/column index calculation utilities.
 *
 * GSWBaseParser serves as the foundation for more specialized parsers in the
 * GSWeb framework, such as template parsers and declaration parsers. It
 * maintains an internal Unicode character buffer for efficient parsing
 * operations and provides methods to track parsing position with accurate
 * line and column reporting for error messages and debugging.
 *
 * Key features:
 * - Unicode character buffer management for efficient parsing
 * - Line and column position tracking throughout parsing operations
 * - Utility methods for common parsing tasks and position reporting
 * - Foundation for specialized GSWeb parsers
 */

// $Id$

#ifndef _GSWBaseParser_h__
	#define _GSWBaseParser_h__


//====================================================================
/**
 * The GSWBaseParser class provides fundamental parsing capabilities for
 * GSWeb template and declaration processing. This abstract base class
 * maintains parsing state and provides utility methods for position
 * tracking, line/column calculation, and common parsing operations.
 */
@interface GSWBaseParser : NSObject
{
  NSString* _string;     /** The source string being parsed */
  unichar* _uniBuf;      /** Unicode character buffer for efficient access */
  int _length;           /** Total length of the source string */
  int _index;            /** Current parsing position index */
}
/**
 * Returns a formatted string describing the current parsing position in
 * terms of line and column numbers. This method is useful for generating
 * human-readable error messages and debugging output that shows exactly
 * where in the source text the parser is currently positioned.
 */
-(NSString*)currentLineAndColumnIndexesString;

/**
 * Returns a formatted string describing the line and column position
 * corresponding to the specified character index within the source text.
 * This allows conversion from absolute character positions to human-readable
 * line and column coordinates for any position in the parsed content.
 */
-(NSString*)lineAndColumnIndexesStringFromIndex:(int)index;

/**
 * Returns the line number (zero-based) corresponding to the current
 * parsing position. This provides just the line information without
 * column details, useful for quick line-based position tracking.
 */
-(int)currentLineIndex;

/**
 * Returns the line number (zero-based) corresponding to the specified
 * character index within the source text. This allows determination
 * of line position for any character index in the parsed content.
 */
-(int)lineIndexFromIndex:(int)index;

/**
 * Calculates and returns both line and column indexes for the specified
 * character position through the provided pointer parameters. This method
 * provides the most efficient way to obtain both coordinates simultaneously
 * when both line and column information are needed.
 */
-(void)lineAndColumnIndexesFromIndex:(int)index
                    returnsLineIndex:(int*)lineIndexPtr
                         columnIndex:(int*)colIndexPtr;
@end

/**
 * Debug logging function for parser buffer state. This function logs detailed
 * information about the parser's current buffer state including position,
 * remaining characters, and context information. Used internally for debugging
 * parser operations and troubleshooting parsing issues.
 */
void
_ParserDebugLogBuffer(char* fn, char* file, int line, unichar* uniBuf,
		      int length, int index, int charsCount);

/**
 * Convenience macro for logging parser buffer state with automatic capture
 * of function name, file, and line information. This provides an easy way
 * to add debug logging throughout parser code.
 */
#define ParserDebugLogBuffer(uniBuf,length,index,charsCount) \
	_ParserDebugLogBuffer(__PRETTY_FUNCTION__,	\
	__FILE__, __LINE__, uniBuf, length, index, charsCount)

/**
 * Inline utility function that tests whether a Unicode character represents
 * a decimal digit (0-9). This provides efficient character classification
 * for numeric parsing operations commonly needed in template and declaration
 * parsing.
 */
static inline BOOL _parserIsDigit(unichar c)
{
  return ((c>='0' && c<='9') ? YES: NO);
};

/**
 * Inline utility function that tests whether a Unicode character represents
 * a hexadecimal digit (0-9, A-F, a-f). This provides efficient character
 * classification for hexadecimal parsing operations, useful for color values,
 * escape sequences, and other hex-encoded content in templates.
 */
static inline BOOL _parserIsHexDigit(unichar c)
{
  return (((c>='0' && c<='9')
           || (c>='A' && c<='F')
           || (c>='a' && c<='f')) ? YES: NO);
};

/**
 * Inline utility function that tests whether a Unicode character represents
 * whitespace or blank characters. This includes space, tab, form feed,
 * carriage return, newline, and vertical tab characters. Essential for
 * parsing operations that need to skip or handle whitespace appropriately.
 */
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

/**
 * Inline utility function that tests whether a Unicode character represents
 * an end-of-line character (carriage return or newline). This is specifically
 * focused on line termination detection, useful for line-based parsing
 * operations and accurate line counting during template processing.
 */
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
