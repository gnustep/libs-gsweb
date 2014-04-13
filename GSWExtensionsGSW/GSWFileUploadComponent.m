/** GSWFileUploadComponent.m - <title>GSWeb: Class GSWFileUploadComponent</title>

   Copyright (C) 2002-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	May 2002
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWExtGSWWOCompatibility.h"
#include "GSWFileUploadComponent.h"
//====================================================================
@implementation GSWFileUploadComponent

//--------------------------------------------------------------------
-(void)awake
{
  [super awake];
  _tmpFileInfo=nil;
};

//--------------------------------------------------------------------
-(void)sleep
{
  _tmpFileInfo=nil;
  [super sleep];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_tmpWithAndHeight);
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
  _tmpFileInfo=nil;
  [aResponse appendDebugCommentContentString:[[self fileInfo]description]];

  [super appendToResponse:aResponse
         inContext:aContext];
  _tmpFileInfo=nil;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  _tmpFileInfo=nil;
  [super takeValuesFromRequest:aRequest
         inContext:aContext];

  if ([[_tmpFileInfo valueForKey:@"data"]length]>0 || boolValueWithDefaultFor([_tmpFileInfo valueForKey:@"isDeleted"],NO))
    [self setValue:_tmpFileInfo
          forBinding:@"fileInfo"];
  _tmpFileInfo=nil;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)fileInfo
{
  if (!_tmpFileInfo)
    {
      if ([self hasBinding:@"fileInfo"])
        {
          _tmpFileInfo=[[[self valueForBinding:@"fileInfo"] mutableCopy] autorelease];
          if (!_tmpFileInfo)
            _tmpFileInfo=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        };
    };

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

//--------------------------------------------------------------------
-(BOOL)hasWidthAndHeightList
{
  return ([self valueForBinding:@"isDeleteEnabled"]!=nil);
};

//--------------------------------------------------------------------
-(NSString*)fileName
{
  NSMutableDictionary* fileInfo=[self fileInfo];
  NSString* fileName = [fileInfo objectForKey:@"fileName"];
  if (!fileName || fileName==(NSString*)[NSNull null])
    {
      fileName=[fileInfo objectForKey:@"filePath"];
      if (!fileName || fileName==(NSString*)[NSNull null])
        {
          fileName = [fileInfo objectForKey:@"fileURL"];
          if (fileName==(NSString*)[NSNull null])
            fileName=nil;
        };
    };
  if (fileName)
    fileName=[fileName lastPathComponent];
  else
    fileName=@"";
  return fileName;
};

//--------------------------------------------------------------------
-(BOOL)isFileNameDisplay
{
  BOOL isFileNameDisplay=boolValueFor([self valueForBinding:@"isFileNameDisplay"]);
  if (isFileNameDisplay
      && [[self fileName]length]==0)
    isFileNameDisplay=NO;
  return isFileNameDisplay;
};

//--------------------------------------------------------------------
-(BOOL)hasUploadFileTitle
{
  return (([self hasBinding:@"uploadFileTitle"]
           && [[self valueForBinding:@"uploadFileTitle"] length]>0));
};
@end


