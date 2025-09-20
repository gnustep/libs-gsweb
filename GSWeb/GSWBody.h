/** GSWBody.h - <title>GSWeb: Class GSWBody</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999

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

/**
 * GSWBody represents the HTML &lt;body&gt; element within GSWeb components,
 * providing a dynamic element for generating HTML body tags with attributes
 * and URL-based functionality. This class extends GSWHTMLURLValuedElement
 * to support standard HTML body element features including background images,
 * colors, and event handlers.
 *
 * As part of the GSWeb framework's HTML generation system, GSWBody enables
 * components to produce well-formed HTML body elements with dynamic content
 * and attributes that can be bound to component properties or computed
 * dynamically during page rendering.
 *
 * Key features:
 * - HTML &lt;body&gt; tag generation with proper attributes
 * - Support for background images and colors through URL handling
 * - Integration with GSWeb's binding system for dynamic attribute values
 * - Inheritance of URL-valued element capabilities for resource handling
 * - Seamless integration with component template rendering
 */

// $Id$

#ifndef _GSWBody_h__
	#define _GSWBody_h__


//====================================================================
/**
 * GSWBody provides HTML &lt;body&gt; element generation for GSWeb components.
 * This dynamic element class extends GSWHTMLURLValuedElement to support
 * body tag creation with URL-based attributes such as background images.
 *
 * The class inherits all URL-valued element capabilities from its parent
 * class, enabling it to handle resource URLs for backgrounds and other
 * URL-based body attributes. It integrates seamlessly with GSWeb's
 * template system to produce standards-compliant HTML body elements
 * with dynamic attribute binding support.
 *
 * Common usage includes generating body tags with:
 * - Background image URLs
 * - Background colors and styling attributes
 * - Event handler attributes (onload, onunload, etc.)
 * - CSS class and style attributes
 * - Any other standard HTML body element attributes
 */
@interface GSWBody: GSWHTMLURLValuedElement
@end


#endif //_GSWBody_h__
