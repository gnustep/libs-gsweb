/** GSWLongResponsePage.m - <title>GSWeb: Class GSWLongResponsePage</title>

   Copyright (C) 2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sep 2002
   
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

#ifndef _GSWLongResponsePage_h__
	#define _GSWLongResponsePage_h__


//==============================================================================
@interface GSWLongResponsePage: GSWComponent <NSLocking> 
{
@private
  id _status;
  id _result;
  NSException *_exception;
  NSRecursiveLock *_selfLock;
  NSTimeInterval _refreshInterval;
  BOOL _performingAction;
  BOOL _cancelled;
  BOOL _done;
}

/** Locks the page **/
- (void)lock;

/** Unlock the page **/
- (void)unlock;

/** Set status (Lock protected) **/
- (void)setStatus:(id)status;

/** Set the refresh interval. Default is 0. If >0, a refresh header is appended to the response **/
- (void)setRefreshInterval:(NSTimeInterval)interval;

/** Get the refresh interval. **/
- (NSTimeInterval)refreshInterval;

/** Return YES if action is canceled by the user. Used to abort thread.  (Lock protected) **/
- (BOOL)isCancelled;

/** This method should be overwritten to return a result. Default implementation raise an exception
Warning: you should first increase app worker thread count. 
count=1 ==> you code don't nead to be thread safe
count>1 ==> if your code is not thread safe, you should disable concurrent request handling
count>1 ==> if your code is thread safe, you can enable concurrent request handling
**/
- (id)performAction;

/** This method is call by GSWMetaRefresh -invokeAction.
It can be manually called (for example if the page does not refresh itself.
Status value make it call -pageForException:, -pageForResult:, -refreshPageForStatus: or -cancelPageForStatus:
Don't override it
**/
- (GSWComponent *)refresh;


- (GSWComponent *)cancel;
/* TODO the cancel action sets cancel to yes and calls cancelPageForStatus:. DO NOT OVERRIDE */

/** Called when an exception occur in the process thread. Replace -pageForResult: call.
Default implemnetation raise the exception **/
- (GSWComponent *)pageForException:(NSException *)exception;

/** Called when the process thread is done.
Default implementation stops automatic refresh and returns self.
You can override this to return a newly created result page
**/
- (GSWComponent *)pageForResult:(id) result;

/** Called on each refresh. Should return self. **/
- (GSWComponent *)refreshPageForStatus:(id) status;

/** Called when the process thread is cancelled. Replace -pageForResult: call.
Default implementation stops automatic refresh and returns self.
**/
- (GSWComponent *)cancelPageForStatus:(id) status;


@end

#endif //_GSWLongResponsePage_h__
