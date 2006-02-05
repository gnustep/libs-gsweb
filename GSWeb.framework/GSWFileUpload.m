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
  
  [super dealloc];
};


- (NSString *) type
{
  return @"file";
}

-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
 // nothing!
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
 // nothing!
}

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //Bypass GSWInput
  return nil;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  if ((![self disabledInComponent: component]) && ([context _wasFormSubmitted])) {
    GSWComponent* component=nil;
    NSString* nameInContext=nil;
    NSArray* fileDatas=nil;
    NSString* fileNameFormValueName=nil;
    NSString* fileNameValue=nil;
    NSData* dataValue=nil;
    int fileDatasCount=0;
    NS_DURING
      {
        component=GSWContext_component(context);
        nameInContext=[self nameInContext:context];
        NSDebugMLLog(@"gswdync",@"nameInContext=%@",nameInContext);
        fileDatas=[request formValuesForKey:nameInContext];
        NSDebugMLLog(@"gswdync",@"value=%@",fileDatas);
        fileDatasCount=[fileDatas count];
        /*
          if (_fileDatasCount!=1)
          {
          ExceptionRaise(@"GSWFileUpload",
          @"GSWFileUpload: File Data Nb != 1 :%d",
          _fileDatasCount);
          };
        */
        if (fileDatasCount==1) 
          {
            dataValue=[fileDatas objectAtIndex:0];
            NSDebugMLLog(@"gswdync",@"dataValue %p (class=%@)=%@",
                         dataValue,[dataValue class],dataValue);
            if (dataValue)
              {
                if ([dataValue isKindOfClass:[NSData class]])
                  {
                    if ([dataValue length]==0)
                      {
                        LOGError(@"Empty Data: %@",dataValue);					  
                      };
                  }
                else
                  {
                    if ([dataValue isKindOfClass:[NSString class]] && [dataValue length]==0)
                      {
                        LOGError(@"No Data: %@",dataValue);
                        NSDebugMLLog(@"gswdync",@"No Data: %p (class=%@)=%@",
                                     dataValue,[dataValue class],dataValue);
                        dataValue=nil;
                      }
                    else
                      {
                        NSLog(@"content type request : %@",[request _contentType]);
                        NSLog(@"data class = %@",NSStringFromClass([dataValue class]));
                        NSDebugMLLog(@"gswdync",@"??Data: %p (class=%@)=%@",
                                     dataValue,[dataValue class],dataValue);
                        /*if (![dataValue isMemberOfClass:[NSString class]]) {
                          ExceptionRaise(@"GSWFileUpload",
                          @"GSWFileUpload: bad data :%@",
                          dataValue);
                          dataValue=nil;
                          }*/
                      };
                  };
              }
            else
              {
                LOGError0(@"No Data:");
              };
            fileNameFormValueName=[NSString stringWithFormat:@"%@.filename",nameInContext];
            NSDebugMLLog(@"gswdync",@"fileNameFormValueName=%@",fileNameFormValueName);
            fileNameValue=[request formValueForKey:fileNameFormValueName];
            NSDebugMLLog(@"gswdync",@"fileNameValue=%@",fileNameValue);
            if (!fileNameValue || [fileNameValue length]==0)
              {
                LOGError(@"No fileName: %@",fileNameValue);
              };
            [_filepath setValue:fileNameValue
                       inComponent:component];
            [_data setValue:dataValue
                   inComponent:component];
  } 
        else 
          {
            // bug in omniweb-browser if you click cancel in FileOpenPanel, it transmits incorrect datas
            
            [_filepath setValue:nil
                       inComponent:component];
            [_data setValue:nil
                   inComponent:component];
  }
      }
    NS_HANDLER
      {
        localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                 @"GSWFileUpload in takeValuesFromRequest");
        LOGException(@"%@ (%@)",localException,[localException reason]);
        [localException raise];
      };
    NS_ENDHANDLER;
  };
};


@end

