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
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWFileUpload");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements_=%@",
               aName,associations,elements);
  [tmpAssociations setObject:[GSWAssociation associationWithValue:@"file"]
                   forKey:@"type"];
  [tmpAssociations removeObjectForKey:data__Key];
  [tmpAssociations removeObjectForKey:filePath__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil])) //No Childs!
    {
      _data = [[associations objectForKey:data__Key
                             withDefaultObject:[_data autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWFileUpload: data=%@",_data);

      if (!_data || ![_data isValueSettable])
        {
          //TODO
        };
      
      _filepath = [[associations objectForKey:filePath__Key
                                 withDefaultObject:[_filepath autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWFileUpload: filepath=%@",_filepath);
      
      if (!_filepath || ![_filepath isValueSettable])
        {
          //TODO
        };
    };
  LOGObjectFnStopC("GSWFileUpload");
  return self;
};


//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_data);
  DESTROY(_filepath);
  [super dealloc];
};

@end
//====================================================================
@implementation GSWFileUpload (GSWFileUploadA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  [super appendToResponse:response
		 inContext:context];
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  //Bypass GSWInput
  return nil;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  BOOL disabledValue=NO;
  LOGObjectFnStartC("GSWFileUpload");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      BOOL wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=nil;
          NSString* nameInContext=nil;
          NSArray* fileDatas=nil;
          NSString* fileNameFormValueName=nil;
          NSString* fileNameValue=nil;
          NSData* dataValue=nil;
          int fileDatasCount=0;
          NS_DURING
            {
              component=[context component];
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
  LOGObjectFnStopC("GSWFileUpload");
};
@end

