/** GSWBaseParser.m - <title>GSWeb: Class GSWBaseParser</title>

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
#include "GSWBaseParser.h"


//====================================================================
@implementation GSWBaseParser

//--------------------------------------------------------------------
+(void)initialize
{
  if (self == [GSWBaseParser class])
    {
    };
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_string);
  if (_uniBuf)
    {
      NSZoneFree(NSDefaultMallocZone(),_uniBuf);
      _uniBuf=NULL;
    };
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)currentLineAndColumnIndexesString
{
  return [self lineAndColumnIndexesStringFromIndex:_index];
}

//--------------------------------------------------------------------
-(NSString*)lineAndColumnIndexesStringFromIndex:(int)index
{
  int lineIndex=0;
  int columnIndex=0;
  [self lineAndColumnIndexesFromIndex:index
        returnsLineIndex:&lineIndex
        columnIndex:&columnIndex];
  return [NSString stringWithFormat:@"(line: %d column: %d)",
                   lineIndex,columnIndex];  
}

//--------------------------------------------------------------------
-(int)currentLineIndex
{
  return [self lineIndexFromIndex:_index];
}

//--------------------------------------------------------------------
-(int)lineIndexFromIndex:(int)index
{
  int lineIndex=0;
  [self lineAndColumnIndexesFromIndex:index
        returnsLineIndex:&lineIndex
        columnIndex:NULL];
  return lineIndex;
};

//--------------------------------------------------------------------
-(void)lineAndColumnIndexesFromIndex:(int)index
                    returnsLineIndex:(int*)lineIndexPtr
                         columnIndex:(int*)colIndexPtr
{
  int lineIndex=0;
  int columnIndex=0;
  int i=0;

  if (index>=_length)
    {
      lineIndex=999999;
      columnIndex=0;
    };
  for(i=0;i<index && i<_length;i++)
    {
      if (_uniBuf[i]=='\n')
        {
          lineIndex++;
          columnIndex=0;
        }
      else
        columnIndex++;
    };
  if (lineIndexPtr)
    *lineIndexPtr=lineIndex;
  if (colIndexPtr)
    *colIndexPtr=columnIndex;
};

@end

void _ParserDebugLogBuffer(char* fn,char* file,int line,unichar* uniBuf,int length,int index,int charsCount)
{
  int i=0;
  printf("In %s (%s %d): length=%d index=%d ==>\n",fn,file,line,length,index);
  for(i=index;i<length && i-index<charsCount;i++)
    printf("%c",(char)(uniBuf[i]));
  printf("\n");
  fflush(stdout);
}
