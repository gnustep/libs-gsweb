/** GSWFileUploadComponent.m - <title>GSWeb: Class GSWFileUploadComponent</title>
   Copyright (C) 2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		May 2002
   
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

#include "GSWExtGSWWOCompatibility.h"
#include "GSWFileUploadComponent.h"
//====================================================================
@implementation GSWFileUploadComponent

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  _tmpFileInfo=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  _tmpFileInfo=nil;
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  [aResponse appendDebugCommentContentString:[[self fileInfo]description]];
  [super appendToResponse:aResponse
         inContext:aContext];
  _tmpFileInfo=nil;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  NSDebugMLog(@"fileInfo %@",_tmpFileInfo);
  [super takeValuesFromRequest:aRequest
         inContext:aContext];
  NSDebugMLog(@"fileInfo.fileURL %@",[_tmpFileInfo valueForKey:@"fileURL"]);
  NSDebugMLog(@"fileInfo.fileName %@",[_tmpFileInfo valueForKey:@"fileName"]);
  NSDebugMLog(@"fileInfo.filePath %@",[_tmpFileInfo valueForKey:@"filePath"]);
  NSDebugMLog(@"fileInfo.data %p",[_tmpFileInfo valueForKey:@"data"]);
  NSDebugMLog(@"fileInfo.data length %d",(int)[[_tmpFileInfo valueForKey:@"data"] length]);
  NSDebugMLog(@"fileInfo.mimeType %@",[_tmpFileInfo valueForKey:@"mimeType"]);
  NSDebugMLog(@"fileInfo.isDeleted %@",[_tmpFileInfo valueForKey:@"isDeleted"]);
  if ([[_tmpFileInfo valueForKey:@"data"]length]>0 || boolValueWithDefaultFor([_tmpFileInfo valueForKey:@"isDeleted"],NO))
    [self setValue:_tmpFileInfo
          forBinding:@"fileInfo"];
  _tmpFileInfo=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)fileInfo
{
  LOGObjectFnStart();
  if (!_tmpFileInfo)
    {
      if ([self hasBinding:@"fileInfo"])
        {
          _tmpFileInfo=[[[self valueForBinding:@"fileInfo"] mutableCopy] autorelease];
          if (!_tmpFileInfo)
            _tmpFileInfo=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        };
    };
  LOGObjectFnStop();
  return _tmpFileInfo;
};

//--------------------------------------------------------------------
-(BOOL)isViewEnabled
{
  BOOL isViewEnabled=YES;
  if ([self hasBinding:@"isViewEnabled"])
    {
      id isViewEnabledObject=[self valueForBinding:@"isViewEnabled"];
      isViewEnabled=boolValueFor(isViewEnabledObject);
    };
  if (isViewEnabled)
    {
      NSMutableDictionary* fileInfo=[self fileInfo];
      isViewEnabled=([fileInfo objectForKey:@"data"]!=nil
                     || [fileInfo objectForKey:@"filePath"]!=nil
                     || [fileInfo objectForKey:@"fileURL"]!=nil);
    };
  return isViewEnabled;
};

//--------------------------------------------------------------------
-(BOOL)isDeleteEnabled
{
  BOOL isDeleteEnabled=NO;
  if ([self hasBinding:@"isDeleteEnabled"])
    {
      id isDeleteEnabledObject=[self valueForBinding:@"isDeleteEnabled"];
      isDeleteEnabled=boolValueFor(isDeleteEnabledObject);
    };
  if (isDeleteEnabled)
    {
      NSMutableDictionary* fileInfo=[self fileInfo];
      isDeleteEnabled=([fileInfo objectForKey:@"data"]!=nil
                       || [fileInfo objectForKey:@"filePath"]!=nil
                       || [fileInfo objectForKey:@"fileURL"]!=nil);
    };
  return isDeleteEnabled;
};

@end


