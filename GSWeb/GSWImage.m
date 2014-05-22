/** GSWImage.m - <title>GSWeb: Class GSWImage</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

//====================================================================
@implementation GSWImage

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*) associations
         template:(GSWElement*)template
{
  BOOL hasFilename=([associations objectForKey: filename__Key] != nil);
  if ((self = [super initWithName: @"img"
		     associations: associations
		     template: template]))
    {
      if (hasFilename)
	{
	  GSWAssignAndRemoveAssociation(&_width,_associations,width__Key);
	  GSWAssignAndRemoveAssociation(&_height,_associations,height__Key);
	}
    }                 
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_width);
  DESTROY(_height);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)valueAttributeName
{
  return @"value";
};

//--------------------------------------------------------------------
-(NSString*)urlAttributeName
{
  return @"src";
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_getClassName(self),
                   (void*)self];
};
 
 
//--------------------------------------------------------------------
/* This class method does not actually exist in WO45 yet it seems subsequent
 * versions implement it to factor out code replicated by mutliple classes
 * across the class hierarchy.
 */
+ (void) _appendFilenameToResponse:(GSWResponse *)   response
                         inContext:(GSWContext *)    context
                         framework:(GSWAssociation*) framework
                          filename:(GSWAssociation*) filename
                             width:(GSWAssociation*) width 
                            height:(GSWAssociation*) height
{
  GSWResourceManager *resourcemanager = [GSWApp resourceManager];
  GSWComponent *component = GSWContext_component(context);
  NSString *fileNameValue = [filename valueInComponent:component];
  NSString *frameworkName = [GSWHTMLDynamicElement _frameworkNameForAssociation:framework
						   inComponent:component];
  NSString *resourceURL = [context _urlForResourceNamed: fileNameValue
				   inFramework: frameworkName];
  
  if (resourceURL != nil)
    {
      NSString *widthStr = nil;
      NSString *heightStr = nil;
      BOOL calculateWidth = NO;
      BOOL calculateHeight = NO;
      
      if (width != nil)
	{
	  widthStr = NSStringWithObject([width valueInComponent:component]);
	  calculateWidth = (widthStr == nil || [widthStr isEqual:@"*"]);
	}
      if (height != nil)
	{
	  heightStr = NSStringWithObject([height valueInComponent:component]);
	  calculateHeight = (heightStr == nil || [heightStr isEqual:@"*"]);
	}
      
      if (calculateWidth || calculateHeight)
	{
	  GSWImageInfo * imageinfo;
	  
	  GSOnceMLog(@"%@: No height or width information provided for '%@'. If possible, this information should be provided for best performance.",
		     NSStringFromClass([self class]), fileNameValue);
	  
	  imageinfo = [resourcemanager _imageInfoForUrl: resourceURL
				       fileName: fileNameValue
				       framework: frameworkName
				       languages: [context languages]];
	  if (imageinfo != nil)
	    {
	      if (calculateWidth)
		widthStr = [imageinfo widthString];
	      if (calculateHeight)
		heightStr = [imageinfo heightString];
	    }
	  else
	    {
	      NSLog(@"%@: Could not get height/width information for image at '%@' '%@' '%@'", 
	            NSStringFromClass([self class]), resourceURL,
		    fileNameValue, frameworkName);
	    }
	}
      
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    @"src",
								    resourceURL,
								    NO);
      
      if (widthStr != nil)
	{
	  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
									@"width",
									widthStr,
									NO);
	}
      if (heightStr != nil)
	{
	  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
									@"height",
									heightStr,
									NO);
	}
    }
  else
    {
      NSString *message 
	= [resourcemanager errorMessageUrlForResourceNamed: fileNameValue
			   inFramework: frameworkName];
	  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
									@"src",
									message,
									NO);
  }
}

//--------------------------------------------------------------------
// used from GSWActiveImage
// _appendImageSizetoResponseInContext

+ (void) _appendImageSizetoResponse:(GSWResponse *) response
                          inContext:(GSWContext *) context
                              width:(GSWAssociation *) width
                             height:(GSWAssociation *) height
{
  GSWComponent * component = GSWContext_component(context);
  NSString     * widthValue = NSStringWithObject([width valueInComponent:component]);
  NSString     * heightValue = NSStringWithObject([height valueInComponent:component]);
   
  if (widthValue != nil)
    {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    @"width",
								    widthValue,
								    NO);
    }
  if (heightValue != nil)
    {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    @"height",
								    heightValue,
								    NO);
    }
}

//--------------------------------------------------------------------
/* This function exists in WO45 and its implementation coresponds
 * to the class method.  Yet insubesquent versions of WO it has
 * been consolidated into the class method.  We keep this method
 * to remain compatible yet internally take advantage of the class method
 * where applicable.
 */
- (void) _appendFilenameToResponse:(GSWResponse *) response
                         inContext:(GSWContext *) context
{
  [GSWImage _appendFilenameToResponse: response
	    inContext: context
	    framework: _framework
	    filename: _filename
	    width: _width
	    height: _height];
}

//--------------------------------------------------------------------
-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
// do nothing!
}

//--------------------------------------------------------------------
/* This function exists in WO45 and its implementation coresponds
 * to the class method of GSWHTMLDynamicElement.  Yet insubesquent
 * versions of WO it has been consolidated into the class method.
 * We keep this method to remain compatible yet internally take
 * advantage of the class method where applicable.
 */
- (NSString*) _frameworkNameInComponent: (GSWComponent *) component
{
  return [GSWHTMLDynamicElement _frameworkNameForAssociation: _framework
				inComponent: component];
}
@end
