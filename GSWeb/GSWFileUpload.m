/** GSWFileUpload.m - <title>GSWeb: Class GSWFileUpload</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sep 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWFileUpload

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"input" associations:associations template: nil];
  if (!self) {
    return nil;
  }

  ASSIGN(_data, [_associations objectForKey: data__Key]);
  if (_data != nil) {
    [_associations removeObjectForKey: data__Key];
  }
  ASSIGN(_filepath, [_associations objectForKey: filePath__Key]);
  if (_filepath != nil) {
    [_associations removeObjectForKey: filePath__Key];
  }
  /* // 5.x stuff....
  ASSIGN(_mimeType, [_associations objectForKey: mimeType__Key]);
  if (_mimeType != nil) {
    [_associations removeObjectForKey: mimeType__Key];
  }
  ASSIGN(_copyData, [_associations objectForKey: copyData__Key]);
  if (_copyData != nil) {
    [_associations removeObjectForKey: copyData__Key];
  }
  ASSIGN(_inputStream, [_associations objectForKey: inputStream__Key]);
  if (_inputStream != nil) {
    [_associations removeObjectForKey: inputStream__Key];
  }
  ASSIGN(_outputStream, [_associations objectForKey: outputStream__Key]);
  if (_outputStream != nil) {
    [_associations removeObjectForKey: inputStream__Key];
  }
  ASSIGN(_bufferSize, [_associations objectForKey: bufferSize__Key]);
  if (_bufferSize != nil) {
    [_associations removeObjectForKey: bufferSize__Key];
  }
  ASSIGN(_streamToFilePath, [_associations objectForKey: streamToFilePath__Key]);
  if (_streamToFilePath != nil) {
    [_associations removeObjectForKey: streamToFilePath__Key];
  }
  ASSIGN(_overwrite, [_associations objectForKey: overwrite__Key]);
  if (_overwrite != nil) {
    [_associations removeObjectForKey: overwrite__Key];
  }
  ASSIGN(_finalFilePath, [_associations objectForKey: finalFilePath__Key]);
  if (_finalFilePath != nil) {
    [_associations removeObjectForKey: finalFilePath__Key];
  }
  */
    
    ASSIGN(_multiple, [_associations objectForKey: multiple__Key]);
    if (_multiple != nil) {
        [_associations removeObjectForKey: multiple__Key];
    }

  if (((_data == nil) && (_filepath == nil)) || ((_data != nil) && (![_data isValueSettable])) ||
      ((_filepath != nil) && (![_filepath isValueSettable]))) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: None of the 'data' or 'filePath' attributes is not present or is a constant. Only exacatly one of the two attributes is allowed.",
                            __PRETTY_FUNCTION__];
  }
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
    DESTROY(_data);
    DESTROY(_filepath);
    DESTROY(_mimeType);
    DESTROY(_copyData);
    DESTROY(_inputStream);
    DESTROY(_outputStream);
    DESTROY(_bufferSize);
    DESTROY(_streamToFilePath);
    DESTROY(_overwrite);
    DESTROY(_finalFilePath);
    DESTROY(_multiple);
    
    [super dealloc];
};


- (NSString *) type
{
  return @"file";
}

-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
    GSWComponent * component = GSWContext_component(context);

    if (_multiple != nil && ([_multiple boolValueInComponent:component])) {
        GSWResponse_appendContentCharacter(response,' ');
        GSWResponse_appendContentAsciiString(response,@"multiple");
    }

}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
 // nothing!
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //Bypass GSWInput
  return nil;
}

/*
 "7.1.filename" =     (
 "15072009(002).jpg",
 "31082009.jpg"
 );
 "7.3" =     (
 Submit
 );
*/

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
    GSWComponent * component = GSWContext_component(context);
    if ((![self disabledInComponent: component]) && ([context _wasFormSubmitted]))
    {
        GSWComponent        * component=nil;
        NSString            * nameInContext=nil;
        NSArray             * fileDatas=nil;
        NSString            * fileNameFormValueName=nil;
        NSString            * mimeValueName=nil;
        NSUInteger            fileDatasCount=0;
        
        NS_DURING
        {
            component=GSWContext_component(context);
            nameInContext=[self nameInContext:context];
            
            fileNameFormValueName = [NSString stringWithFormat:@"%@.filename", nameInContext];
            mimeValueName = [NSString stringWithFormat:@"%@.%@",nameInContext, GSWHTTPHeader_ContentType];
            
            fileDatas = [request formValuesForKey:nameInContext];
                        
            fileDatasCount = [fileDatas count];
            
            if (fileDatasCount >= 1)
            {
                NSArray * fileNameValue = [request formValuesForKey:fileNameFormValueName];
                NSArray * mimeValue = [request formValuesForKey:mimeValueName];;

                if ([[fileNameValue objectAtIndex:0] length] == 0) {
                    fileNameValue = nil;
                    fileDatas = nil;
                    mimeValue = nil;
                }
                
                if (_multiple != nil && ([_multiple boolValueInComponent:component])) {
                    [_filepath setValue:fileNameValue
                            inComponent:component];
                    
                    [_data setValue:fileDatas
                        inComponent:component];
                    
                    [_mimeType setValue:mimeValue
                            inComponent:component];
                } else {
                    
                    [_filepath setValue:[fileNameValue objectAtIndex:0]
                            inComponent:component];
                    
                    [_data setValue:[fileDatas objectAtIndex:0]
                        inComponent:component];
                    
                    [_mimeType setValue:[mimeValue objectAtIndex:0]
                            inComponent:component];
                }
            }
        }
        NS_HANDLER
        {
            localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                     @"GSWFileUpload in takeValuesFromRequest");
            [localException raise];
        }
        NS_ENDHANDLER;
    }
}


@end

