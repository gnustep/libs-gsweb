/** GSWGeometricRegion.h - <title>GSWeb: Class GSWRequest</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sept 1999
   
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

// $Id$

#ifndef _GSWGeometricRegion_h__
	#define _GSWGeometricRegion_h__


//====================================================================
@interface GSWGeometricRegion : NSObject <NSCopying>
{
  NSString* _userDefinedString;
  id _userDefinedValue;
};

+(NSArray*)geometricRegionsWithFile:(NSString*)fileName;
+(NSArray*)geometricRegionsWithString:(NSString*)string;
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape
                          coordinates:(NSArray*)coords
                    userDefinedString:(NSString*)userDefinedString;
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape
                          coordinates:(NSArray*)coords
                    userDefinedString:(NSString*)userDefinedString
                     userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;
-(void)dealloc;
-(id)copyWithZone:(NSZone*)zone;
-(NSString*)description;
-(NSString*)userDefinedString;
-(id)userDefinedValue;
-(BOOL)hitTest:(NSPoint*)point;
-(BOOL)hitTestX:(int)x
              y:(int)y;
+(GSWGeometricRegion*)hitTestX:(int)x
                             y:(int)y
                     inRegions:(NSArray*)regions;


@end 


//====================================================================
@interface GSWArcRegion : GSWGeometricRegion
{
  NSPoint _center;
  NSSize _size;
  int _start; // angle degres
  int _stop; // angle degres
};

+(id)arcRegionWithShape:(NSString*)shape
                 center:(NSPoint)center
                   size:(NSSize)size
                  start:(int)start
                   stop:(int)stop
      userDefinedString:(NSString*)userDefinedString;

+(id)arcRegionWithShape:(NSString*)shape
                 center:(NSPoint)center
                   size:(NSSize)size
                  start:(int)start
                   stop:(int)stop
      userDefinedString:(NSString*)userDefinedString
       userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;


-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
             start:(int)start
              stop:(int)stop
 userDefinedString:(NSString*)userDefinedString;


-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
             start:(int)start
              stop:(int)stop
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;

-(NSString*)description;
-(id)copyWithZone:(NSZone*)zone;
-(BOOL)hitTestX:(int)x
              y:(int)y;

@end 

//====================================================================
@interface GSWEllipseRegion : GSWArcRegion
{
};

+(id)ellipseRegionWithShape:(NSString*)shape
                     center:(NSPoint)center
                       size:(NSSize)size
          userDefinedString:(NSString*)userDefinedString;

+(id)ellipseRegionWithShape:(NSString*)shape
                     center:(NSPoint)center
                       size:(NSSize)size
          userDefinedString:(NSString*)userDefinedString
           userDefinedValue:(id)userDefinedValue;


-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
 userDefinedString:(NSString*)userDefinedString;

-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;

-(NSString*)description;
@end 

//====================================================================
@interface GSWCircularRegion : GSWEllipseRegion
{
};

+(id)circularRegionWithShape:(NSString*)shape
                      center:(NSPoint)center
                    diameter:(int)diameter
           userDefinedString:(NSString*)userDefinedString;

+(id)circularRegionWithShape:(NSString*)shape
                      center:(NSPoint)center
                    diameter:(int)diameter
           userDefinedString:(NSString*)userDefinedString
            userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
          diameter:(int)diameter
 userDefinedString:(NSString*)userDefinedString;
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
          diameter:(int)diameter
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;

-(NSString*)description;

@end 

//====================================================================
@interface GSWRectangularRegion : GSWGeometricRegion
{
  NSRect _rect;
};

+(id)rectangularRegionWithShape:(NSString*)shape
                           rect:(NSRect)rect
              userDefinedString:(NSString*)userDefinedString;
+(id)rectangularRegionWithShape:(NSString*)shape
                           rect:(NSRect)rect
			  userDefinedString:(NSString*)userDefinedString
			   userDefinedValue:(id)userDefinedValue;
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;
-(id)initWithShape:(NSString*)shape
              rect:(NSRect)rect
 userDefinedString:(NSString*)userDefinedString;
-(id)initWithShape:(NSString*)shape
              rect:(NSRect)rect
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;
-(NSString*)description;
-(BOOL)hitTestX:(int)x
              y:(int)y;



@end 

//====================================================================
@interface GSWPolygonRegion : GSWGeometricRegion
{
  NSArray* _points;
};

+(id)polygonRegionWithShape:(NSString*)shape
                coordinates:(NSArray*)coords
		  userDefinedString:(NSString*)userDefinedString;
+(id)polygonRegionWithShape:(NSString*)shape
                coordinates:(NSArray*)coords
          userDefinedString:(NSString*)userDefinedString
           userDefinedValue:(id)userDefinedValue;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString;

-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue;
-(NSString*)description;
-(BOOL)hitTestX:(int)x
              y:(int)y;

@end 

#endif // __GSWGeometricRegion_h_
