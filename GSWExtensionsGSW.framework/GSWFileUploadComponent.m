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

#include <GSWeb/GSWeb.h>
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
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_fileInfo);
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
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  NSDebugMLog(@"fileInfo %@",_fileInfo);
  [super takeValuesFromRequest:aRequest
         inContext:aContext];
  NSDebugMLog(@"fileInfo.fileURL %@",[_fileInfo valueForKey:@"fileURL"]);
  NSDebugMLog(@"fileInfo.fileName %@",[_fileInfo valueForKey:@"fileName"]);
  NSDebugMLog(@"fileInfo.filePath %@",[_fileInfo valueForKey:@"filePath"]);
  NSDebugMLog(@"fileInfo.data %p",[_fileInfo valueForKey:@"data"]);
  NSDebugMLog(@"fileInfo.mimeType %@",[_fileInfo valueForKey:@"mimeType"]);
  NSDebugMLog(@"fileInfo.isDeleted %@",[_fileInfo valueForKey:@"isDeleted"]);
  if ([[_fileInfo valueForKey:@"data"]length]>0 || boolValueWithDefaultFor([_fileInfo valueForKey:@"isDeleted"],NO))
    [self setValue:_fileInfo
          forBinding:@"fileInfo"];
  DESTROY(_fileInfo);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)fileInfo
{
  LOGObjectFnStart();
  if (!_fileInfo)
    {
      if ([self hasBinding:@"fileInfo"])
        {
          _fileInfo=[[self valueForBinding:@"fileInfo"] mutableCopy];
          if (!_fileInfo)
            _fileInfo=[NSMutableDictionary new];
        };
    };
  LOGObjectFnStop();
  return _fileInfo;
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


