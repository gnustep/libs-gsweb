/* GSWGeometricRegion.h - GSWeb: Class GSWRequest
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Sept 1999
   
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

#ifndef _GSWGeometricRegion_h__
	#define _GSWGeometricRegion_h__


//====================================================================
@interface GSWGeometricRegion : NSObject <NSCopying>
{
  NSString* userDefinedString;
  id userDefinedValue;
};

+(NSArray*)geometricRegionsWithFile:(NSString*)fileName_;
+(NSArray*)geometricRegionsWithString:(NSString*)string_;
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape_
						  coordinates:(NSArray*)coords
					userDefinedString:(NSString*)userDefinedString_;
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape_
						  coordinates:(NSArray*)coords
					userDefinedString:(NSString*)userDefinedString_
					 userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_;
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;
-(void)dealloc;
-(id)copyWithZone:(NSZone*)zone_;
-(NSString*)description;
-(NSString*)userDefinedString;
-(id)userDefinedValue;
-(BOOL)hitTest:(NSPoint*)point_;
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_;
+(GSWGeometricRegion*)hitTestX:(int)x_
							 y:(int)y_
					 inRegions:(NSArray*)regions_;


@end 


//====================================================================
@interface GSWArcRegion : GSWGeometricRegion
{
  NSPoint center;
  NSSize size;
  int start; // angle degres
  int stop; // angle degres
};

+(id)arcRegionWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start
			  stop:(int)stop
 userDefinedString:(NSString*)userDefinedString_;

+(id)arcRegionWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start
			  stop:(int)stop
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;


-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start
			  stop:(int)stop
 userDefinedString:(NSString*)userDefinedString_;


-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start
			  stop:(int)stop
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(NSString*)description;
-(id)copyWithZone:(NSZone*)zone_;
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_;




@end 

//====================================================================
@interface GSWEllipseRegion : GSWArcRegion
{
};

+(id)ellipseRegionWithShape:(NSString*)shape_
					 center:(NSPoint)center_
					   size:(NSSize)size_
		  userDefinedString:(NSString*)userDefinedString_;

+(id)ellipseRegionWithShape:(NSString*)shape_
					 center:(NSPoint)center_
					   size:(NSSize)size_
		  userDefinedString:(NSString*)userDefinedString_
		   userDefinedValue:(id)userDefinedValue_;


-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
 userDefinedString:(NSString*)userDefinedString_;

-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(NSString*)description;
@end 

//====================================================================
@interface GSWCircularRegion : GSWEllipseRegion
{
};

+(id)circularRegionWithShape:(NSString*)shape_
					  center:(NSPoint)center_
					diameter:(int)diameter_
		  userDefinedString:(NSString*)userDefinedString_;

+(id)circularRegionWithShape:(NSString*)shape_
					  center:(NSPoint)center_
					diameter:(int)diameter_
		  userDefinedString:(NSString*)userDefinedString_
			userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
		  diameter:(int)diameter_
 userDefinedString:(NSString*)userDefinedString_;
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
		  diameter:(int)diameter_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;

-(NSString*)description;

@end 

//====================================================================
@interface GSWRectangularRegion : GSWGeometricRegion
{
  NSRect rect;
};

+(id)rectangularRegionWithShape:(NSString*)shape_
						   rect:(NSRect)rect_
			  userDefinedString:(NSString*)userDefinedString_;
+(id)rectangularRegionWithShape:(NSString*)shape_
						   rect:(NSRect)rect_
			  userDefinedString:(NSString*)userDefinedString_
			   userDefinedValue:(id)userDefinedValue_;
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_;
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;
-(id)initWithShape:(NSString*)shape_
			  rect:(NSRect)rect_
 userDefinedString:(NSString*)userDefinedString_;
-(id)initWithShape:(NSString*)shape_
			  rect:(NSRect)rect_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;
-(NSString*)description;
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_;



@end 

//====================================================================
@interface GSWPolygonRegion : GSWGeometricRegion
{
  NSArray* points;
};

+(id)polygonRegionWithShape:(NSString*)shape_
				coordinates:(NSArray*)coords
		  userDefinedString:(NSString*)userDefinedString_;
+(id)polygonRegionWithShape:(NSString*)shape_
				coordinates:(NSArray*)coords
		  userDefinedString:(NSString*)userDefinedString_
		   userDefinedValue:(id)userDefinedValue_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString_;

-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;
-(NSString*)description;
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_;

@end 

#endif __GSWGeometricRegion_h_
