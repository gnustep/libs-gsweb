/** FileUpload1Page.h - <title>GSWeb Testing: Class FileUpload1Page</title>

   Copyright (C) 2006 Free Software Foundation, Inc.
   
   Written by:	David Ayers  <ayers@fsfe.org>
   Date: 	Aug 2006
   
   $Revision: 0 $
   $Date: 2006-08-24 10:46:22 +0100 (Thr, 24 Aug 2006) $

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

// $Id: FileUpload1Page.h 0 2006-08-24 10:46:22Z ayers $

#ifndef _FileUpload1Page_h__
	#define _FileUpload1Page_h__

@interface FileUpload1Page: BasePage
{
  id aFilePath;
  id aFileData;
}
@end

#endif //_FileUpload1Page_h__
