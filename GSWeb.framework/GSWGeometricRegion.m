/* GSWGeometricRegion.m - GSWeb: Class GSWRequest
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>
#include <math.h>


//--------------------------------------------------------------------
double rad2deg(double rad)
{
  double _pi=acos(-1);
  double _deg=rad*180/_pi;
  return _deg;
};

//--------------------------------------------------------------------
double deg2rad(double deg)
{
  double _pi=acos(-1);
  double _rad=deg*_pi/180;
  return _rad;
};

//--------------------------------------------------------------------
float distanceBetweenPoints(NSPoint pt1, NSPoint pt2)
{
  return sqrt(pow(pt2.x-pt1.x,2)+pow(pt2.y-pt1.y,2));
};

//--------------------------------------------------------------------
BOOL isOnSegment(NSPoint m,NSPoint a,NSPoint b)
{
  BOOL _isOnSegment=(((m.x-a.x)*(b.y-a.y)-(m.y-a.y)*(b.x-a.x))==0);
  if (_isOnSegment)
	{
	  NSPoint a1=NSMakePoint(min(a.x,b.x),min(a.y,b.y));
	  NSPoint b1=NSMakePoint(max(a.x,b.x),max(a.y,b.y));
	  _isOnSegment=m.x>=a1.x && m.x<=b1.x && m.y>=a1.y && m.y<=b1.y;
	};
  return _isOnSegment;
};

//--------------------------------------------------------------------
// Test on UP direction
BOOL canBeOnSegment(NSPoint m,NSPoint a,NSPoint b)
{
  BOOL _canBeOnSegment=YES;
  float y=0;
  if (a.x==b.x)
	{
	  if (m.x==a.x)
		y=max(a.y,b.y);
	  else
		_canBeOnSegment=NO;
	}
  else
	{
	  y=(float)(a.y*(b.x-a.x)-(b.y-a.y)*(a.x+m.x));
	  y/=((float)(a.x-b.x));
	};
	
  if (_canBeOnSegment)
	_canBeOnSegment=m.y<=y;
  return _canBeOnSegment;
};

//====================================================================
@implementation GSWGeometricRegion

//--------------------------------------------------------------------
+(NSArray*)geometricRegionsWithFile:(NSString*)fileName_
{
  NSArray* _regions=nil;
  NSString* _string=[NSString stringWithContentsOfFile:fileName_];
  if (!_string)
	{
	  ExceptionRaise(@"GSWGeometricRegion: Can't open File '%@'",
					  fileName_);
	}
  else
	_regions=[self geometricRegionsWithString:_string];
  return _regions;
}

//--------------------------------------------------------------------
+(NSArray*)geometricRegionsWithString:(NSString*)string_
{
  NSMutableArray* _regions=[NSMutableArray array];
  NSArray* _regionsStrings=nil;
  NSString* _shapeType=nil;
  NSString* _userDefinedString=nil;
  NSString* _shape=nil;
  int _x=0;
  int _y=0;
  int i=0;
  int _regionsCount=0;					  
  GSWGeometricRegion* _region=nil;
  string_=[string_ stringByReplacingString:@"\r\n"
				   withString:@"\n"];
  _regionsStrings=[string_ componentsSeparatedByString:@"\n"];
  _regionsCount=[_regionsStrings count];		
  for(i=0;i<_regionsCount;i++)
	{
	  NSString* _regionString=[_regionsStrings objectAtIndex:i];
	  NSScanner* _scanner=[NSScanner scannerWithString:_shape];
	  if ([_scanner scanUpToString:@" "
					intoString:&_shapeType])
		{
		  if ([_scanner scanUpToString:@" "
						intoString:&_userDefinedString])
			{
			  NSMutableArray* _coords=[NSMutableArray array];
			  while (![_scanner isAtEnd])
				{
				  if ([_scanner scanInt:&_x]
					  && [_scanner scanString:@"," intoString:NULL])
					{
					  if ([_scanner scanInt:&_y])
						{
						  [_coords addObject:[NSValue valueWithPoint:NSMakePoint(_x,_y)]];
						}
					  else
						{
						  ExceptionRaise(@"GSWGeometricRegion: Can't parse an y coord in line %@",
										 _regionString);
						};
					}
				  else
					{
					  ExceptionRaise(@"GSWGeometricRegion: Can't parse an x coord in line %@",
									  _regionString);
					};
				};
			  _region=[self regionWithShape:_shapeType
							coordinates:_coords
							userDefinedString:_userDefinedString];
			  if (_region)
				{
				  [_regions addObject:_region];
				}
			  else
				{
				  ExceptionRaise(@"GSWGeometricRegion: Can't make region '%@' whith userDefinedString %@ and coords %@",
								  _shapeType,
								  _userDefinedString,
								  _coords);
				};
			}
		  else
			{
			  ExceptionRaise(@"GSWGeometricRegion: Can't parse userDefinedString in line %@",
							  _regionString);
			};
		}
	  else
		{
		  ExceptionRaise(@"GSWGeometricRegion: Can't parse shapeType in line %@",
						 _regionString);
		};
	};  
  return [NSArray arrayWithArray:_regions];
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape_
						  coordinates:(NSArray*)coords_
					userDefinedString:(NSString*)userDefinedString_
{
  return [self regionWithShape:shape_
			   coordinates:coords_
			   userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)regionWithShape:(NSString*)shape_
						  coordinates:(NSArray*)coords_
					userDefinedString:(NSString*)userDefinedString_
					 userDefinedValue:(id)userDefinedValue_
{
  GSWGeometricRegion* _region=nil;
  if ([shape_ isEqualToString:@"rect"])
	{
	  _region=[[[GSWRectangularRegion alloc]initWithShape:shape_
											coordinates:coords_
											userDefinedString:userDefinedString_
											userDefinedValue:userDefinedValue_]autorelease];
	}
  else if ([shape_ isEqualToString:@"circle"])
	{
	  _region=[[[GSWCircularRegion alloc]initWithShape:shape_
										 coordinates:coords_
										 userDefinedString:userDefinedString_
											userDefinedValue:userDefinedValue_]autorelease];
	}
  else if ([shape_ isEqualToString:@"poly"])
	{
	  _region=[[[GSWPolygonRegion alloc]initWithShape:shape_
										coordinates:coords_
										userDefinedString:userDefinedString_
											userDefinedValue:userDefinedValue_]autorelease];
	}
  else if ([shape_ isEqualToString:@"ellipse"])
	{
	  _region=[[[GSWEllipseRegion alloc]initWithShape:shape_
										coordinates:coords_
										userDefinedString:userDefinedString_
											userDefinedValue:userDefinedValue_]autorelease];
	}
  else if ([shape_ isEqualToString:@"arc"])
	{
	  _region=[[[GSWArcRegion alloc]initWithShape:shape_
									coordinates:coords_
									userDefinedString:userDefinedString_
											userDefinedValue:userDefinedValue_]autorelease];
	}
  else
	{
	  ExceptionRaise(@"GSWGeometricRegion bad shape %@ (userDefinedString = %@)",
					 shape_,
					 userDefinedString_);
	};
  return _region;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};
//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_;
{
  if ((self=[super init]))
	{
	  ASSIGN(userDefinedString,userDefinedString_);
	  ASSIGN(userDefinedValue,userDefinedValue_);
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(userDefinedString);
  DESTROY(userDefinedValue);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWGeometricRegion* clone = nil;
  LOGObjectFnStart();
  clone=[[isa allocWithZone:zone_] init];
  if (clone)
	{
	  ASSIGN(clone->userDefinedString,userDefinedString);
	};
  LOGObjectFnStop();
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@>",
				   object_get_class_name(self),
				   (void*)self,
				   userDefinedString,
				   userDefinedValue];
};

//--------------------------------------------------------------------
-(NSString*)userDefinedString
{
  return userDefinedString;
};

//--------------------------------------------------------------------
-(id)userDefinedValue
{
  return userDefinedValue;
};

//--------------------------------------------------------------------
-(BOOL)hitTest:(NSPoint*)point_
{
  if (point_)
	return [self hitTestX:(unsigned int)point_->x
				 y:(unsigned int)point_->y];
  else
	return NO;
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_
{
  [self subclassResponsibility: _cmd];
  return NO;
};

//--------------------------------------------------------------------
+(GSWGeometricRegion*)hitTestX:(int)x_
							 y:(int)y_
					 inRegions:(NSArray*)regions_
{
  GSWGeometricRegion* _regionFound=nil;
  int i=0;
  int _count=[regions_ count];
  GSWGeometricRegion* _region=nil;
  for(i=0;!_regionFound && i<_count;i++)
	{
	  _region=[regions_ objectAtIndex:i];
	  if ([_region hitTestX:x_
				   y:y_])
		{
		  _regionFound=_region;
		};		  
	};
  NSDebugMLLog(@"low",@"_regionFound=%@",_regionFound);
  return _regionFound;
};

@end 


//====================================================================
@implementation GSWArcRegion : GSWGeometricRegion

//--------------------------------------------------------------------
+(id)arcRegionWithShape:(NSString*)shape_
				 center:(NSPoint)center_
				   size:(NSSize)size_
				  start:(int)start_
				   stop:(int)stop_
	  userDefinedString:(NSString*)userDefinedString_
{
  return [self arcRegionWithShape:shape_
			   center:center_
			   size:size_
			   start:start_
			   stop:stop_
			   userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)arcRegionWithShape:(NSString*)shape_
				 center:(NSPoint)center_
				   size:(NSSize)size_
				  start:(int)start_
				   stop:(int)stop_
	  userDefinedString:(NSString*)userDefinedString_
	   userDefinedValue:(id)userDefinedValue_
{
  return [[[self alloc]initWithShape:shape_
					   center:center_
					   size:size_
					   start:start_
					   stop:stop_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ([coords_ count]!=3)
	{
	  ExceptionRaise(@"GSWArcRegion",
					 @"GSWArcRegion bad number of coordinates (center x,center y width,height start angle,stop angle):%@ [userDefinedString = %@]",
					 coords_,
					 userDefinedString_);
	}
  else
	{
	  if ((self=[super initWithShape:shape_
					   coordinates:coords_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_]))
		{
		  NSPoint _startStop=[[coords_ objectAtIndex:2] pointValue];
		  NSPoint _size=[[coords_ objectAtIndex:1] pointValue];
		  center=[[coords_ objectAtIndex:0] pointValue];
		  size=NSMakeSize(_size.x,_size.y);
		  start=min(_startStop.x,_startStop.y);
		  stop=max(_startStop.x,_startStop.y);
		};
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start_
			  stop:(int)stop_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  center:center_
				  size:size_
				  start:start_
				  stop:stop_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};
//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
			 start:(int)start_
			  stop:(int)stop_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ((self=[super initWithShape:shape_
				   coordinates:nil
				   userDefinedString:userDefinedString_
				   userDefinedValue:userDefinedValue_]))
	{
	  center=center_;
	  size=size_;
	  start=start_;
	  stop=stop_;
	};
  return self;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWArcRegion* clone = nil;
  LOGObjectFnStart();
  clone = [super copyWithZone:zone_];
  if (clone)
	{
	  clone->center=center;
	  clone->size=size;
	  clone->start=start;
	  clone->stop=stop;	  
	};
  LOGObjectFnStop();
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ center %@ size %@ start %d stop %d>",
				   object_get_class_name(self),
				   (void*)self,
				   userDefinedString,
				   userDefinedValue,
				   NSStringFromPoint(center),
				   NSStringFromSize(size),
				   start,
				   stop];
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_
{
  BOOL _hitOk=NO;
  NSPoint _test=NSMakePoint(x_,y_);
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"self=%@\nx=%u y=%u",self,x_,y_);
  if (size.width==0)	
	_hitOk=isOnSegment(_test,
					   NSMakePoint(center.x,center.x-size.height/2),
					   NSMakePoint(center.x,center.x+size.height/2));
  else if (size.height==0)
	_hitOk=isOnSegment(_test,
					   NSMakePoint(center.x-size.width/2,center.y),
					   NSMakePoint(center.x+size.width/2,center.y));
  else
	{
	  float _cosWith=(x_-center.x);
	  NSDebugMLLog(@"low",@"_cosWith=%f",(double)_cosWith);
	  if (_cosWith>=-size.width/2 && _cosWith<=size.width/2)
		{
		  float _sinHeight=(y_-center.y);
		  NSDebugMLLog(@"low",@"_sinHeight=%f",(double)_sinHeight);
		  if (_sinHeight>=-size.height/2 && _sinHeight<=size.height/2)
			{
			  double _pi=acos(-1);
			  float _distance=distanceBetweenPoints(center,_test);
			  float _cos=_cosWith/_distance;
			  float _sin=_sinHeight/_distance;
			  float _cosAngleRad=acos(_cos);
			  float _sinAngleRad=asin(_sin);
			  float _angleRad=((_sinAngleRad<0) ? (2*_pi-_cosAngleRad) : _cosAngleRad);
			  float _angleDeg=rad2deg(_angleRad);
			  NSDebugMLLog(@"low",@"_distance=%f",(double)_distance);
			  NSDebugMLLog(@"low",@"_cos=%f",(double)_cos);
			  NSDebugMLLog(@"low",@"_sin=%f",(double)_sin);
			  NSDebugMLLog(@"low",@"_cosAngleRad=%f",(double)_cosAngleRad);
			  NSDebugMLLog(@"low",@"_sinAngleRad=%f",(double)_sinAngleRad);
			  NSDebugMLLog(@"low",@"_angleRad=%f",(double)_angleRad);
			  NSDebugMLLog(@"low",@"_angleDeg=%f",(double)_angleDeg);
			  _hitOk=(_angleDeg>=start && _angleDeg<=stop);
			};
		};
	};
  NSDebugMLLog(@"low",@"_hitOk=%s",(_hitOk ? "YES" : "NO"));
  LOGObjectFnStop();
  return _hitOk;
};

@end 

//====================================================================
@implementation GSWEllipseRegion : GSWArcRegion

//--------------------------------------------------------------------
+(id)ellipseRegionWithShape:(NSString*)shape_
					 center:(NSPoint)center_
					   size:(NSSize)size_
		  userDefinedString:(NSString*)userDefinedString_
{
  return [self ellipseRegionWithShape:shape_
			   center:center_
			   size:size_
			   userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)ellipseRegionWithShape:(NSString*)shape_
					 center:(NSPoint)center_
					   size:(NSSize)size_
		  userDefinedString:(NSString*)userDefinedString_
		   userDefinedValue:(id)userDefinedValue_
{
  return [[[self alloc]initWithShape:shape_
					   center:center_
					   size:size_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ([coords_ count]!=2)
	{
	  ExceptionRaise(@"GSWEllipseRegion",
					 @"GSWEllipseRegion bad number of coordinates (center x,center y width,height):%@ [userDefinedString = %@]",
					 coords_,
					 userDefinedString_ );
	}
  else
	{
	  NSPoint _center=[[coords_ objectAtIndex:0] pointValue];
	  NSPoint _tmpSize=[[coords_ objectAtIndex:1] pointValue];
	  NSSize _size=NSMakeSize(_tmpSize.x,_tmpSize.y);
	  if ((self=[self initWithShape:shape_
					  center:_center
					  size:_size
					  userDefinedString:userDefinedString_
					  userDefinedValue:userDefinedValue_]))
		{
		};
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  center:center_
				  size:size_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
			  size:(NSSize)size_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ((self=[super initWithShape:shape_
				   center:center_
				   size:size_
				   start:0
				   stop:360
				   userDefinedString:userDefinedString_
				   userDefinedValue:userDefinedValue_]))
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
+(id)circularRegionWithShape:(NSString*)shape_
					  center:(NSPoint)center_
					diameter:(int)diameter_
		  userDefinedString:(NSString*)userDefinedString_
{
  return [self circularRegionWithShape:shape_
			   center:center_
			   diameter:diameter_
			   userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};
//--------------------------------------------------------------------
+(id)circularRegionWithShape:(NSString*)shape_
					  center:(NSPoint)center_
					diameter:(int)diameter_
		  userDefinedString:(NSString*)userDefinedString_
			userDefinedValue:(id)userDefinedValue_
{
  return [[[self alloc]initWithShape:shape_
					   center:center_
					   diameter:diameter_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ([coords_ count]!=2)
	{
	  ExceptionRaise(@"GSWCircularRegion",
					 @"GSWCircularRegion bad number of coordinates (only center and edgePoint are possible):%@ [userDefinedString = %@]",
					 coords_,
					 userDefinedString_ );
	}
  else
	{
	  NSPoint _center=[[coords_ objectAtIndex:0] pointValue];
	  NSPoint _edgePoint=[[coords_ objectAtIndex:1] pointValue];
	  int rayon=(int)distanceBetweenPoints(_center,_edgePoint);
	  if ((self=[self initWithShape:shape_
					  center:_center
					  diameter:rayon*2
					  userDefinedString:userDefinedString_
					  userDefinedValue:userDefinedValue_]))
		{
		};
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
		  diameter:(int)diameter_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  center:center_
				  diameter:diameter_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			center:(NSPoint)center_
		  diameter:(int)diameter_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ((self=[super initWithShape:shape_
				   center:center_
				   size:NSMakeSize(diameter_,diameter_)
				   userDefinedString:userDefinedString_
				   userDefinedValue:userDefinedValue_]))
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
+(id)rectangularRegionWithShape:(NSString*)shape_
						   rect:(NSRect)rect_
			  userDefinedString:(NSString*)userDefinedString_
{
  return [self rectangularRegionWithShape:shape_
			   rect:rect_
			   userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)rectangularRegionWithShape:(NSString*)shape_
						   rect:(NSRect)rect_
			  userDefinedString:(NSString*)userDefinedString_
			   userDefinedValue:(id)userDefinedValue_
{
  return [[[self alloc]initWithShape:shape_
					   rect:rect_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ([coords_ count]!=2)
	{
	  ExceptionRaise(@"GSWRectangularRegion",
					 @"GSWRectangularRegion bad number of coordinates (only x1,y1 and x2,y2 allowed):%@ [userDefinedString = %@]",
					 coords_,
					 userDefinedString_ );
	}
  else
	{
	  NSPoint pt0=[[coords_ objectAtIndex:0] pointValue];
	  NSPoint pt1=[[coords_ objectAtIndex:1] pointValue];
	  NSRect _rect=NSMakeRect(pt0.x,pt0.y,pt1.x-pt0.x,pt1.y-pt0.y);
	  if ((self=[self initWithShape:shape_
					  rect:_rect
					  userDefinedString:userDefinedString_
					  userDefinedValue:userDefinedValue_]))
		{
		};
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			  rect:(NSRect)rect_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  rect:rect_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
			  rect:(NSRect)rect_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ((self=[super initWithShape:shape_
				   coordinates:nil
				   userDefinedString:userDefinedString_
				   userDefinedValue:userDefinedValue_]))
	{
	  rect=rect_;
	};
  return self;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ rect %@>",
				   object_get_class_name(self),
				   (void*)self,
				   userDefinedString,
				   userDefinedValue,
				   NSStringFromRect(rect)];
};

//--------------------------------------------------------------------
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_
{
  BOOL _hitOk=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"self=%@\nx=%u y=%u",self,x_,y_);
  _hitOk=NSPointInRect(NSMakePoint(x_,y_),rect);
  LOGObjectFnStop();
  return _hitOk;
};

@end 

//====================================================================
@implementation GSWPolygonRegion

//--------------------------------------------------------------------
+(id)polygonRegionWithShape:(NSString*)shape_
				coordinates:(NSArray*)coords_
		  userDefinedString:(NSString*)userDefinedString_
{
  return [self polygonRegionWithShape:shape_
				coordinates:coords_
		  userDefinedString:userDefinedString_
			   userDefinedValue:nil];
};

//--------------------------------------------------------------------
+(id)polygonRegionWithShape:(NSString*)shape_
				coordinates:(NSArray*)coords_
		  userDefinedString:(NSString*)userDefinedString_
		   userDefinedValue:(id)userDefinedValue_
{
  return [[[self alloc]initWithShape:shape_
					   coordinates:coords_
					   userDefinedString:userDefinedString_
					   userDefinedValue:userDefinedValue_] autorelease];
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
{
  if ((self=[self initWithShape:shape_
				  coordinates:coords_
				  userDefinedString:userDefinedString_
				  userDefinedValue:nil]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(id)initWithShape:(NSString*)shape_
	   coordinates:(NSArray*)coords_
 userDefinedString:(NSString*)userDefinedString_
  userDefinedValue:(id)userDefinedValue_
{
  if ((self=[super initWithShape:shape_
				   coordinates:coords_
				   userDefinedString:userDefinedString_
				   userDefinedValue:userDefinedValue_]))
	{
	  if ([coords_ count]==0)
		{
		  ExceptionRaise(@"GSWPolygonRegion",
						 @"GSWPolygonRegion bad number of coordinates (at least 1 point needed):%@ [userDefinedString = %@]",
						 coords_,
						 userDefinedString_ );
		}
	  else
		{
		  ASSIGN(points,coords_);
		};
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(points);
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - userDefinedString %@ userDefinedValue %@ points %@>",
				   object_get_class_name(self),
				   (void*)self,
				   userDefinedString,
				   userDefinedValue,
				   points];
};


//--------------------------------------------------------------------
-(BOOL)hitTestX:(unsigned int)x_
			  y:(unsigned int)y_
{
  BOOL _hitOk=NO;
  int i=0;
  int _count=[points count];
  NSPoint _lastPoint;
  NSPoint _currentPoint;
  NSPoint _test=NSMakePoint(x_,y_);
  if (_count==1)
	{	  
	  _currentPoint=[[points objectAtIndex:0] pointValue];
	  _hitOk=(x_==_currentPoint.x && y_==_currentPoint.y);
	}
  else if (_count==2)
	{	 
	  _lastPoint=[[points objectAtIndex:0] pointValue];
	  _currentPoint=[[points objectAtIndex:1] pointValue];
	  _hitOk=isOnSegment(_test,_lastPoint,_currentPoint);
	}
  else
	{
	  int _crossCount=0;
	  // A point is in the polygon if the line segment starting from the point 
	  // and going anywhere meete an odd number of polygon segment !
	  _lastPoint=[[points objectAtIndex:0] pointValue];
	  for(i=1;i<=_count;i++)
		{
		  _currentPoint=[[points objectAtIndex:(i%_count)] pointValue];
		  // Test on UP direction
		  if (canBeOnSegment(_test,_lastPoint,_currentPoint))
			_crossCount++;
		  _lastPoint=_currentPoint;
		};
	  _hitOk=((_crossCount%2)!=0);
	};
  return _hitOk;
};

@end 


