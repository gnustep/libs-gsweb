/* GSWStatsPage.h - GSWeb: Class GSWStatsPage
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Apr 1999
   
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

#ifndef _GSWStatsPage_h__
	#define _GSWStatsPage_h__


//==============================================================================
@interface GSWStatsPage: GSWComponent
{
  NSString* _tmpKey;
  NSString* _tmpItem;

  NSDictionary* _detailsDict;
  NSDictionary* _pagesDict;
  NSDictionary* _directActionsDict;
  NSDictionary* _sessionMemoryDict;
  NSDictionary* _transactions;
  NSDictionary* _statsDict;
  NSDictionary* _memoryDict;
  NSArray* _sessionStats;
  NSMutableDictionary* _sessionsDict;
  NSNumber* _maxPageCount;
  NSNumber* _maxActionCount;
  NSDate* _maxSessionsDate;
  NSString* _userName;
  NSString* _password;
};

-(id)submit;
-(id)host;
-(id)instance;
-(NSNumber*)_maxServedForDictionary:(NSDictionary*)aDictionary;
-(id)_initIvars;
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;
-(void)setDetailPercent:(NSNumber*)aValue;
-(NSNumber*)detailPercent;
-(id)runningTime;
-(id)detailCount;

@end

#endif //_GSWStatsPage_h__
