/* GSWLoadBalancing.h - GSWeb: GSWeb Load Balancing
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jully 1999
   
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

#ifndef _GSWLoadBalancing_h__
#define _GSWLoadBalancing_h__

BOOL GSWLoadBalancing_FindApp(GSWAppRequest* p_pAppRequest,void* p_pLogServerData);
BOOL GSWLoadBalancing_FindInstance(GSWAppRequest* p_pAppRequest,void* p_pLogServerData);
void GSWLoadBalancing_MarkNotRespondingApp(GSWAppRequest* p_pAppRequest,void* p_pLogServerData);
void GSWLoadBalancing_StartAppRequest(GSWAppRequest* p_pAppRequest,void* p_pLogServerData);
void GSWLoadBalancing_StopAppRequest(GSWAppRequest* p_pAppRequest,void* p_pLogServerData);

#endif // GSWLoadBalancing

