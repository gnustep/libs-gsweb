/** GSWComponentDefinition.h - <title>GSWeb: Class GSWComponentDefinition</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWComponentDefinition_h__
	#define _GSWComponentDefinition_h__

//====================================================================
@interface GSWComponentDefinition : NSObject <NSCoding,NSCopying>
{
  NSString * _name;
  NSString * _path;        // _pathURL
  NSString * _url;
  NSString * _frameworkName;
  NSString * _language;
  NSString * _className;
  Class _componentClass;
  BOOL _caching;
  BOOL _isAwake;
  GSWElement * _template;
  NSString * _htmlPath;
  NSString * _wodPath;
  NSString * _wooPath;
//  BOOL missingArchive;  // NO "_" prefix?? dw
  NSDictionary * _archive;
  NSStringEncoding _encoding;
  BOOL _isStateless;
  GSWDeployedBundle * _bundle;
  GSWComponent * _sharedInstance;
  NSMutableArray * _instancePool;
  BOOL _lockInstancePool;
  BOOL _hasBeenAccessed;
  BOOL _hasContextConstructor;
  NSLock * _instancePoolLock;
};

-(id)initWithName:(NSString*)aName
             path:(NSString*)aPath
          baseURL:(NSString*)baseURL
    frameworkName:(NSString*)aFrameworkName;

-(Class) componentClass;


-(NSString*)frameworkName;
-(NSString*)baseURL;
-(NSString*)path;
-(NSString*)name;
-(NSString*)description;
-(void)sleep;
-(void)awake;
- (BOOL) isStateless;

// PRIVATE
+ (GSWContext *) TheTemporaryContext;

-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag;

@end



#endif //GSWComponentDefinition
