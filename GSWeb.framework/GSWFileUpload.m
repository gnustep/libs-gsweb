/* GSWFileUpload.h - GSWeb: Class GSWFileUpload
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Sep 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWFileUpload

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStartC("GSWFileUpload");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  [_associations setObject:[GSWAssociation associationWithValue:@"file"]
				 forKey:@"type"];
  [_associations removeObjectForKey:data__Key];
  [_associations removeObjectForKey:filePath__Key];
  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil])) //No Childs!
	{
	  data = [[associations_ objectForKey:data__Key
							 withDefaultObject:[data autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWFileUpload: data=%@",data);

	  if (!data || ![data isValueSettable])
		{
		  //TODO
		};

	  filepath = [[associations_ objectForKey:filePath__Key
							 withDefaultObject:[filepath autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWFileUpload: filepath=%@",filepath);

	  if (!filepath || ![filepath isValueSettable])
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
  DESTROY(data);
  DESTROY(filepath);
  [super dealloc];
};

@end
//====================================================================
@implementation GSWFileUpload (GSWFileUploadA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  [super appendToResponse:response_
		 inContext:context_];
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						   inContext:(GSWContext*)context_
{
  GSWAssertCorrectElementID(context_);// Debug Only
  //Bypass GSWInput
  return nil;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabled=NO;
  LOGObjectFnStartC("GSWFileUpload");
  GSWAssertCorrectElementID(context_);// Debug Only
  _disabled=[self disabledInContext:context_];
  if (!_disabled)
	{
	  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
	  if (_wasFormSubmitted)
		{
		  GSWComponent* _component=nil;
		  NSString* _nameInContext=nil;
		  NSArray* _fileDatas=nil;
		  NSString* fileNameFormValueName=nil;
		  NSString* _fileName=nil;
		  NSData* _data=nil;
		  int _fileDatasCount=0;
		  NS_DURING
		    {
			  _component=[context_ component];
			  _nameInContext=[self nameInContext:context_];
			  NSDebugMLLog(@"gswdync",@"_nameInContext=%@",_nameInContext);
			  _fileDatas=[request_ formValuesForKey:_nameInContext];
			  NSDebugMLLog(@"gswdync",@"_value=%@",_fileDatas);
			  _fileDatasCount=[_fileDatas count];
		      if (_fileDatasCount!=1)
				{
				  ExceptionRaise(@"GSWFileUpload",
								 @"GSWFileUpload: File Data Nb != 1 :%d",
								 _fileDatasCount);
				};
			  _data=[_fileDatas objectAtIndex:0];
			  if (_data)
				{
				  if ([_data isKindOfClass:[NSData class]])
					{
					  if ([_data length]==0)
						{
						  LOGError(@"Empty Data: %@",_data);					  
						};
					}
				  else
					{
					  if ([_data isKindOfClass:[NSString class]] && [_data length]==0)
						{
						  LOGError(@"No Data: %@",_data);
						  _data=nil;
						}
					  else
						{
						  ExceptionRaise(@"GSWFileUpload",
										 @"GSWFileUpload: bad data :%@",
										 _data);
						  _data=nil;
						};
					};
				}
			  else
				{
				  LOGError0(@"No Data:");
				};
			  fileNameFormValueName=[NSString stringWithFormat:@"%@.filename",_nameInContext];
			  NSDebugMLLog(@"gswdync",@"fileNameFormValueName=%@",fileNameFormValueName);
			  _fileName=[request_ formValueForKey:fileNameFormValueName];
			  NSDebugMLLog(@"gswdync",@"_fileName=%@",_fileName);
			  if (!_fileName || [_fileName length]==0)
				{
				  LOGError(@"No fileName: %@",_fileName);
				};
			  [filepath setValue:_fileName
						inComponent:_component];
			  [data setValue:_data
					inComponent:_component];
		    }
		  NS_HANDLER
		    {
		      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWFileUpload in takeValuesFromRequest");
		      LOGException(@"%@ (%@)",localException,[localException reason]);
		      [localException raise];
		    };
		  NS_ENDHANDLER;
		};
	};
  LOGObjectFnStopC("GSWFileUpload");
};
@end

