/* GSWRepetition.h - GSWeb: Class GSWRepetition
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

// $Id$

#ifndef _GSWRepetition_h__
	#define _GSWRepetition_h__

//====================================================================
@interface GSWRepetition: GSWDynamicElement
{
  GSWAssociation* list;
  GSWAssociation* item;
  GSWAssociation* identifier;
  GSWAssociation* count;
  GSWAssociation* index;
  GSWHTMLStaticGroup* childrenGroup;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_;

-(NSString*)description;
-(void)dealloc;

@end

//====================================================================
@interface GSWRepetition (GSWRepetitionA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

-(GSWElement*)_slowInvokeActionForRequest:(GSWRequest*)request_
							   inContext:(GSWContext*)context_;

-(GSWElement*)_fastInvokeActionForRequest:(GSWRequest*)request_
							   inContext:(GSWContext*)context_;

-(void)stopOneIterationWithIndex:(int)index_
						   count:(int)count_
					   isLastOne:(BOOL)isLastOne_
					   inContext:(GSWContext*)context_;
-(void)startOneIterationWithIndex:(unsigned int)index_
							 list:(NSArray*)list_
						inContext:(GSWContext*)context_;
@end


#endif //_GSWRepetition_h__
