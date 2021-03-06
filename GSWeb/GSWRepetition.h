/** GSWRepetition.h - <title>GSWeb: Class GSWRepetition</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
      
   $Revision$
   $Date$
   
   <abstract></abstract>

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

#ifndef _GSWRepetition_h__
	#define _GSWRepetition_h__

//====================================================================

// NOTE: identifier is not used anywhere. There seems to be a documentation bug.

@interface GSWRepetition: GSWDynamicGroup
{
  GSWAssociation* _list;
  GSWAssociation* _item;
  GSWAssociation* _count;
  GSWAssociation* _index;
//GSWeb Additions {
  GSWAssociation* _startIndex; /** Don't begin at 0 but at startIndex **/
  GSWAssociation* _stopIndex;  /** Don't end at count-1 or list count -1  but at stopIndex **/
//}
};

@end


#endif //_GSWRepetition_h__
