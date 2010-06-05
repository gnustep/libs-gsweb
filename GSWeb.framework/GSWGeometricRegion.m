/** GSWGeometricRegion.m - <title>GSWeb: Class GSWRequest</title>

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include <math.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>


//--------------------------------------------------------------------
double rad2deg(double rad)
{
  double pi=acos(-1);
  double deg=rad*180/pi;
  return deg;
};

//--------------------------------------------------------------------
double deg2rad(double deg)
{
  double pi=acos(-1);
  double rad=deg*pi/180;
  return rad;
};

//--------------------------------------------------------------------
float distanceBetweenPoints(NSPoint pt1, NSPoint pt2)
{
  return sqrt(pow(pt2.x-pt1.x,2)+pow(pt2.y-pt1.y,2));
};

//--------------------------------------------------------------------
BOOL isOnSegment(NSPoint m,NSPoint a,NSPoint b)
{
  BOOL isOnSegment=(((m.x-a.x)*(b.y-a.y)-(m.y-a.y)*(b.x-a.x))==0);
  if (isOnSegment)
    {
      NSPoint a1=NSMakePoint(min(a.x,b.x),min(a.y,b.y));
      NSPoint b1=NSMakePoint(max(a.x,b.x),max(a.y,b.y));
      isOnSegment=m.x>=a1.x && m.x<=b1.x && m.y>=a1.y && m.y<=b1.y;
    };
  return isOnSegment;
};

//--------------------------------------------------------------------
// Test on UP direction
BOOL canBeOnSegment(NSPoint m,NSPoint a,NSPoint b)
{
  BOOL canBeOnSegment=YES;
  float y=0;
  if (a.x==b.x)
    {
      if (m.x==a.x)
        y=max(a.y,b.y);
      else
        canBeOnSegment=NO;
    }
  else
    {
      y=(float)(a.y*(b.x-a.x)-(b.y-a.y)*(a.x+m.x));
      y/=((float)(a.x-b.x));
    };
  
  if (canBeOnSegment)
    canBeOnSegment=m.y<=y;
  return canBeOnSegment;
};

//====================================================================
@implementation GSWGeometricRegion

//--------------------------------------------------------------------
+(NSArray*)geometricRegionsWithFile:(NSString*)fileName
{
  NSArray* regions=nil;
  NSString* string=[NSString stringWithContentsOfFile:fileName];
  if (!string)
    {
      ExceptionRaise(@"GSWGeometricRegion: Can't open File '%@'",
                     fileName);
    }
  else
    regions=[self geometricRegionsWithString:string];
  return regions;
}

//--------------------------------------------------------------------
+(NSArray*)geometricRegionsWithString:(NSString*)string
{
  NSMutableArray* regions=[NSMutableArray array];
  NSArray* regionsStrings=nil;
  NSString* shapeType=nil;
  NSString* userDefinedString=nil;
  NSString* shape=nil;
  int x=0;
  int y=0;
  int i=0;
  int regionsCount=0;					  
  GSWGeometricRegion* region=nil;
  string=[string stringByReplacingString:@"\r\n"
                 withString:@"\n"];
  regionsStrings=[string componentsSeparatedByString:@"\n"];
  regionsCount=[regionsStrings count];		
  for(i=0;i<regionsCount;i++)
    {
      NSString* regionString=[regionsStrings objectAtIndex:i];
      NSScanner* scanner=[NSScanner scannerWithString:shape];
      if ([scanner scanUpToString:@" "
                   intoString:&shapeType])
        {
          if ([scanner scanUpToString:@" "
                       intoString:&userDefinedString])
            {
              NSMutableArray* coords=[NSMutableArray array];
              while (![scanner isAtEnd])
                {
                  if ([scanner scanInt:&x]
                      && [scanner scanString:@"," intoString:NULL])
                    {
                      if ([scanner scanInt:&y])
                        {
                          [coords addObject:[NSValue valueWithPoint:NSMakePoint(x,y)]];
                        }
                      else
                        {
                          ExceptionRaise(@"GSWGeometricRegion: Can't parse an y coord in line %@",
                                         regionString);
                        };
                    }
                  else
                    {
                      ExceptionRaise(@"GSWGeometricRegion: Can't parse an x coord in line %@",
                                     regionString);
                    };
                };
              region=[self regionWithShape:shapeType
                           coordinates:coords
                           userDefinedString:userDefinedString];
              if (region)
                {
                  [regions addObject:region];
                }
              else
                {
                  ExceptionRaise(@"GSWGeometricRegion: Can't make region '%@' whith userDefinedString %@ and coords %@",
                                 shapeType,
                                 userDefinedString,
                                 coords);
                };
            }
          else
            {
              ExceptionRaise(@"GSWGeometricRegion: Can't parse userDefinedString in line %@",
                             regionString);
            };
        }
      else
        {
          ExceptionRaise(@"GSWGeometricRegion: Can't parse shapeType in line %@",
                         regionString);
        };
    };  
  return [NSArray arrayWithArray:regions];
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape
                          coordinates:(NSArray*)coords
                    userDefinedString:(NSString*)userDefinedString
{
  return [self regionWithShape:shape
               coordinates:coords
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape
                          coordinates:(NSArray*)coords
                    userDefinedString:(NSString*)userDefinedString
                     userDefinedValue:(id)userDefinedValue
{
  GSWGeometricRegion* region=nil;
  if ([shape isEqualToString:@"rect"])
    {
      region=[[[GSWRectangularRegion alloc]initWithShape:shape
                                           coordinates:coords
                                           userDefinedString:userDefinedString
                                           userDefinedValue:userDefinedValue]autorelease];
    }
  else if ([shape isEqualToString:@"circle"])
    {
      region=[[[GSWCircularRegion alloc]initWithShape:shape
                                        coordinates:coords
                                        userDefinedString:userDefinedString
                                        userDefinedValue:userDefinedValue]autorelease];
    }
  else if ([shape isEqualToString:@"poly"])
    {
      region=[[[GSWPolygonRegion alloc]initWithShape:shape
                                       coordinates:coords
                                       userDefinedString:userDefinedString
                                       userDefinedValue:userDefinedValue]autorelease];
    }
  else if ([shape isEqualToString:@"ellipse"])
    {
      region=[[[GSWEllipseRegion alloc]initWithShape:shape
                                       coordinates:coords
                                       userDefinedString:userDefinedString
                                       userDefinedValue:userDefinedValue]autorelease];
    }
  else if ([shape isEqualToString:@"arc"])
    {
      region=[[[GSWArcRegion alloc]initWithShape:shape
                                   coordinates:coords
                                   userDefinedString:userDefinedString
                                   userDefinedValue:userDefinedValue]autorelease];
    }
  else
    {
      ExceptionRaise(@"GSWGeometricRegion bad shape %@ (userDefinedString = %@)",
                     shape,
                     userDefinedString);
    };
  return region;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};
//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super init]))
    {
      ASSIGN(_userDefinedString,userDefinedString);
      ASSIGN(_userDefinedValue,userDefinedValue);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_userDefinedString);
  DESTROY(_userDefinedValue);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWGeometricRegion* clone = nil;
  clone=[[isa allocWithZone:zone] init];
  if (clone)
    {
      ASSIGN(clone->_userDefinedString,_userDefinedString);
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@>",
                   object_getClassName(self),
                   (void*)self,
                   _userDefinedString,
                   _userDefinedValue];
};

//--------------------------------------------------------------------
-(NSString*)userDefinedString
{
  return _userDefinedString;
};

//--------------------------------------------------------------------
-(id)userDefinedValue
{
  return _userDefinedValue;
};

//--------------------------------------------------------------------
-(BOOL)hitTest:(NSPoint*)point
{
  if (point)
    return [self hitTestX:(int)point->x
                 y:(int)point->y];
  else
    return NO;
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(int)x
              y:(int)y
{
  [self subclassResponsibility: _cmd];
  return NO;
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)hitTestX:(int)x
                             y:(int)y
                     inRegions:(NSArray*)regions
{
  GSWGeometricRegion* regionFound=nil;
  int i=0;
  int count=[regions count];
  GSWGeometricRegion* region=nil;
  for(i=0;!regionFound && i<count;i++)
    {
      region=[regions objectAtIndex:i];
      if ([region hitTestX:x
                  y:y])
        {
          regionFound=region;
        };		  
    };
  NSDebugMLLog(@"low",@"regionFound=%@",regionFound);
  return regionFound;
};

@end 


//====================================================================
@implementation GSWArcRegion : GSWGeometricRegion

//--------------------------------------------------------------------
+(id)arcRegionWithShape:(NSString*)shape
                 center:(NSPoint)center
                   size:(NSSize)size
                  start:(int)start
                   stop:(int)stop
	  userDefinedString:(NSString*)userDefinedString
{
  return [self arcRegionWithShape:shape
               center:center
               size:size
               start:start
               stop:stop
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)arcRegionWithShape:(NSString*)shape
                 center:(NSPoint)center
                   size:(NSSize)size
                  start:(int)start
                   stop:(int)stop
      userDefinedString:(NSString*)userDefinedString
       userDefinedValue:(id)userDefinedValue
{
  return [[[self alloc]initWithShape:shape
                       center:center
                       size:size
                       start:start
                       stop:stop
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ([coords count]!=3)
    {
      ExceptionRaise(@"GSWArcRegion",
                     @"GSWArcRegion bad number of coordinates (center x,center y width,height start angle,stop angle):%@ [userDefinedString = %@]",
                     coords,
                     userDefinedString);
    }
  else
    {
      if ((self=[super initWithShape:shape
                       coordinates:coords
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue]))
        {
          NSPoint startStop=[[coords objectAtIndex:2] pointValue];
          NSPoint tmpSize=[[coords objectAtIndex:1] pointValue];
          _center=[[coords objectAtIndex:0] pointValue];
          _size=NSMakeSize(tmpSize.x,tmpSize.y);
          _start=min(startStop.x,startStop.y);
          _stop=max(startStop.x,startStop.y);
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
             start:(int)start
              stop:(int)stop
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  center:center
                  size:size
                  start:start
                  stop:stop
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};
//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
             start:(int)start
              stop:(int)stop
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super initWithShape:shape
                   coordinates:nil
                   userDefinedString:userDefinedString
                   userDefinedValue:userDefinedValue]))
    {
      _center=center;
      _size=size;
      _start=start;
      _stop=stop;
    };
  return self;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWArcRegion* clone = nil;
  clone = [super copyWithZone:zone];
  if (clone)
    {
      clone->_center=_center;
      clone->_size=_size;
      clone->_start=_start;
      clone->_stop=_stop;	  
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ center %@ size %@ start %d stop %d>",
                   object_getClassName(self),
                   (void*)self,
                   _userDefinedString,
                   _userDefinedValue,
                   NSStringFromPoint(_center),
                   NSStringFromSize(_size),
                   _start,
                   _stop];
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(int)x
              y:(int)y
{
  BOOL hitOk=NO;
  NSPoint test=NSMakePoint(x,y);
  NSDebugMLLog(@"low",@"self=%@\nx=%u y=%u",self,x,y);
  if (_size.width==0)	
    hitOk=isOnSegment(test,
                      NSMakePoint(_center.x,_center.x-_size.height/2),
                      NSMakePoint(_center.x,_center.x+_size.height/2));
  else if (_size.height==0)
    hitOk=isOnSegment(test,
                      NSMakePoint(_center.x-_size.width/2,_center.y),
                      NSMakePoint(_center.x+_size.width/2,_center.y));
  else
    {
      float cosWith=(x-_center.x);
      NSDebugMLLog(@"low",@"cosWith=%f",(double)cosWith);
      if (cosWith>=-_size.width/2 && cosWith<=_size.width/2)
        {
          float sinHeight=(y-_center.y);
          NSDebugMLLog(@"low",@"sinHeight=%f",(double)sinHeight);
          if (sinHeight>=-_size.height/2 && sinHeight<=_size.height/2)
            {
              double pi=acos(-1);
              float distance=distanceBetweenPoints(_center,test);
              float cos=cosWith/distance;
              float sin=sinHeight/distance;
              float cosAngleRad=acos(cos);
              float sinAngleRad=asin(sin);
              float angleRad=((sinAngleRad<0) ? (2*pi-cosAngleRad) : cosAngleRad);
              float angleDeg=rad2deg(angleRad);
              NSDebugMLLog(@"low",@"distance=%f",(double)distance);
              NSDebugMLLog(@"low",@"cos=%f",(double)cos);
              NSDebugMLLog(@"low",@"sin=%f",(double)sin);
              NSDebugMLLog(@"low",@"cosAngleRad=%f",(double)cosAngleRad);
              NSDebugMLLog(@"low",@"sinAngleRad=%f",(double)sinAngleRad);
              NSDebugMLLog(@"low",@"angleRad=%f",(double)angleRad);
              NSDebugMLLog(@"low",@"angleDeg=%f",(double)angleDeg);
              hitOk=(angleDeg>=_start && angleDeg<=_stop);
            };
        };
    };
  NSDebugMLLog(@"low",@"hitOk=%s",(hitOk ? "YES" : "NO"));
  return hitOk;
};

@end 

//====================================================================
@implementation GSWEllipseRegion : GSWArcRegion

//--------------------------------------------------------------------
+(id)ellipseRegionWithShape:(NSString*)shape
                     center:(NSPoint)center
                       size:(NSSize)size
          userDefinedString:(NSString*)userDefinedString
{
  return [self ellipseRegionWithShape:shape
               center:center
               size:size
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)ellipseRegionWithShape:(NSString*)shape
                     center:(NSPoint)center
                       size:(NSSize)size
          userDefinedString:(NSString*)userDefinedString
           userDefinedValue:(id)userDefinedValue
{
  return [[[self alloc]initWithShape:shape
                       center:center
                       size:size
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ([coords count]!=2)
    {
      ExceptionRaise(@"GSWEllipseRegion",
                     @"GSWEllipseRegion bad number of coordinates (center x,center y width,height):%@ [userDefinedString = %@]",
                     coords,
                     userDefinedString);
    }
  else
    {
      NSPoint center=[[coords objectAtIndex:0] pointValue];
      NSPoint tmpSize=[[coords objectAtIndex:1] pointValue];
      NSSize size=NSMakeSize(tmpSize.x,tmpSize.y);
      if ((self=[self initWithShape:shape
                      center:center
                      size:size
                      userDefinedString:userDefinedString
                      userDefinedValue:userDefinedValue]))
        {
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  center:center
                  size:size
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
              size:(NSSize)size
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super initWithShape:shape
                   center:center
                   size:size
                   start:0
                   stop:360
                   userDefinedString:userDefinedString
                   userDefinedValue:userDefinedValue]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [super description];
};

@end 

//====================================================================
@implementation GSWCircularRegion

//--------------------------------------------------------------------
+(id)circularRegionWithShape:(NSString*)shape
                      center:(NSPoint)center
                    diameter:(int)diameter
           userDefinedString:(NSString*)userDefinedString
{
  return [self circularRegionWithShape:shape
               center:center
               diameter:diameter
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};
//--------------------------------------------------------------------
+(id)circularRegionWithShape:(NSString*)shape
                      center:(NSPoint)center
                    diameter:(int)diameter
           userDefinedString:(NSString*)userDefinedString
            userDefinedValue:(id)userDefinedValue
{
  return [[[self alloc]initWithShape:shape
                       center:center
                       diameter:diameter
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ([coords count]!=2)
    {
      ExceptionRaise(@"GSWCircularRegion",
                     @"GSWCircularRegion bad number of coordinates (only center and edgePoint are possible):%@ [userDefinedString = %@]",
                     coords,
                     userDefinedString);
    }
  else
    {
      NSPoint center=[[coords objectAtIndex:0] pointValue];
      NSPoint edgePoint=[[coords objectAtIndex:1] pointValue];
      int rayon=(int)distanceBetweenPoints(center,edgePoint);
      if ((self=[self initWithShape:shape
                      center:center
                      diameter:rayon*2
                      userDefinedString:userDefinedString
                      userDefinedValue:userDefinedValue]))
        {
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
          diameter:(int)diameter
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  center:center
                  diameter:diameter
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
            center:(NSPoint)center
          diameter:(int)diameter
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super initWithShape:shape
                   center:center
                   size:NSMakeSize(diameter,diameter)
                   userDefinedString:userDefinedString
                   userDefinedValue:userDefinedValue]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [super description];
};

@end 

//====================================================================
@implementation GSWRectangularRegion

//--------------------------------------------------------------------
+(id)rectangularRegionWithShape:(NSString*)shape
                           rect:(NSRect)rect
              userDefinedString:(NSString*)userDefinedString
{
  return [self rectangularRegionWithShape:shape
               rect:rect
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)rectangularRegionWithShape:(NSString*)shape
                           rect:(NSRect)rect
              userDefinedString:(NSString*)userDefinedString
               userDefinedValue:(id)userDefinedValue
{
  return [[[self alloc]initWithShape:shape
                       rect:rect
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ([coords count]!=2)
    {
      ExceptionRaise(@"GSWRectangularRegion",
                     @"GSWRectangularRegion bad number of coordinates (only x1,y1 and x2,y2 allowed):%@ [userDefinedString = %@]",
                     coords,
                     userDefinedString);
    }
  else
    {
      NSPoint pt0=[[coords objectAtIndex:0] pointValue];
      NSPoint pt1=[[coords objectAtIndex:1] pointValue];
      NSRect rect=NSMakeRect(pt0.x,pt0.y,pt1.x-pt0.x,pt1.y-pt0.y);
      if ((self=[self initWithShape:shape
                      rect:rect
                      userDefinedString:userDefinedString
                      userDefinedValue:userDefinedValue]))
        {
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
              rect:(NSRect)rect
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  rect:rect
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
              rect:(NSRect)rect
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super initWithShape:shape
                   coordinates:nil
                   userDefinedString:userDefinedString
                   userDefinedValue:userDefinedValue]))
    {
      _rect=rect;
    };
  return self;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ rect %@>",
				   object_getClassName(self),
				   (void*)self,
				   _userDefinedString,
				   _userDefinedValue,
				   NSStringFromRect(_rect)];
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(int)x
              y:(int)y
{
  BOOL hitOk=NO;
  NSDebugMLLog(@"low",@"self=%@\nx=%u y=%u",self,x,y);
  hitOk=NSPointInRect(NSMakePoint(x,y),_rect);
  return hitOk;
};

@end 

//====================================================================
@implementation GSWPolygonRegion

//--------------------------------------------------------------------
+(id)polygonRegionWithShape:(NSString*)shape
                coordinates:(NSArray*)coords
          userDefinedString:(NSString*)userDefinedString
{
  return [self polygonRegionWithShape:shape
               coordinates:coords
               userDefinedString:userDefinedString
               userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)polygonRegionWithShape:(NSString*)shape
                coordinates:(NSArray*)coords
          userDefinedString:(NSString*)userDefinedString
           userDefinedValue:(id)userDefinedValue
{
  return [[[self alloc]initWithShape:shape
                       coordinates:coords
                       userDefinedString:userDefinedString
                       userDefinedValue:userDefinedValue] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
{
  if ((self=[self initWithShape:shape
                  coordinates:coords
                  userDefinedString:userDefinedString
                  userDefinedValue:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape
       coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString
  userDefinedValue:(id)userDefinedValue
{
  if ((self=[super initWithShape:shape
                   coordinates:coords
                   userDefinedString:userDefinedString
                   userDefinedValue:userDefinedValue]))
    {
      if ([coords count]==0)
        {
          ExceptionRaise(@"GSWPolygonRegion",
                         @"GSWPolygonRegion bad number of coordinates (at least 1 point needed):%@ [userDefinedString = %@]",
                         coords,
                         userDefinedString);
        }
      else
        {
          ASSIGN(_points,coords);
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_points);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ points %@>",
                   object_getClassName(self),
                   (void*)self,
                   _userDefinedString,
                   _userDefinedValue,
                   _points];
};


//--------------------------------------------------------------------
-(BOOL)hitTestX:(int)x
              y:(int)y
{
  BOOL hitOk=NO;
  int i=0;
  int count=[_points count];
  NSPoint lastPoint;
  NSPoint currentPoint;
  NSPoint test=NSMakePoint(x,y);
  if (count==1)
    {	  
      currentPoint=[[_points objectAtIndex:0] pointValue];
      hitOk=(x==currentPoint.x && y==currentPoint.y);
    }
  else if (count==2)
    {	 
      lastPoint=[[_points objectAtIndex:0] pointValue];
      currentPoint=[[_points objectAtIndex:1] pointValue];
      hitOk=isOnSegment(test,lastPoint,currentPoint);
    }
  else
    {
      int crossCount=0;
      // A point is in the polygon if the line segment starting from the point 
      // and going anywhere meete an odd number of polygon segment !
      lastPoint=[[_points objectAtIndex:0] pointValue];
      for(i=1;i<=count;i++)
        {
          currentPoint=[[_points objectAtIndex:(i%count)] pointValue];
          // Test on UP direction
          if (canBeOnSegment(test,lastPoint,currentPoint))
            crossCount++;
          lastPoint=currentPoint;
        };
      hitOk=((crossCount%2)!=0);
    };
  return hitOk;
};

@end 


