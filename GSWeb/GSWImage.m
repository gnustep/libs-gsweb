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
  self = [super initWithName: @"img"
                associations: associations
                    template: template];

  if (!self) {
    return nil;
  }

  if ([_associations objectForKey: filename__Key] != nil) {
    ASSIGN(_width, [_associations objectForKey: width__Key]);
    if (_width != nil) {
      [_associations removeObjectForKey: width__Key];
    }
    ASSIGN(_height, [_associations objectForKey: height__Key]);
    if (_height != nil) {
      [_associations removeObjectForKey: height__Key];
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
  GSWResourceManager *resourcemanager;
  GSWComponent *component;
  NSString *fileNameValue;
  NSString *frameworkName = nil;
  NSString *resourceURL;
  
  resourcemanager = [GSWApp resourceManager];
  component = GSWContext_component(context);
  fileNameValue = [filename valueInComponent:component];
  frameworkName = [GSWHTMLDynamicElement _frameworkNameForAssociation:framework
					 inComponent:component];
  
  resourceURL = [context _urlForResourceNamed: fileNameValue
                                  inFramework: frameworkName];
  
  if (resourceURL != nil)
  {
    NSString *widthStr = nil;
    NSString *heightStr = nil;
    BOOL calculateWidth = NO;
    BOOL calculateHeight = NO;
    
    if (width != nil)
    {
      id widthValue;
      widthValue = [width valueInComponent:component];
      if (widthValue)
      {
        widthStr = NSStringWithObject(widthValue);
      }
      calculateWidth = (widthStr == nil || [widthStr isEqual:@"*"]);
    }
    if (height != nil)
    {
      id heightValue;
      heightValue = [height valueInComponent:component];
      if (heightValue)
      {
        heightStr = NSStringWithObject(heightValue);
      }
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
        {
          widthStr = [imageinfo widthString];
        }
	      if (calculateHeight)
        {
          heightStr = [imageinfo heightString];
        }
	    }
      else
	    {
	      NSLog(@"%@: Could not get height/width information for image at '%@' '%@' '%@'", 
	            NSStringFromClass([self class]), resourceURL,
              fileNameValue, frameworkName);
	    }
    }
    
    [response _appendTagAttribute: @"src"
                            value: resourceURL
       escapingHTMLAttributeValue: NO];
    
    if (widthStr != nil)
    {
      [response _appendTagAttribute: @"width"
                              value: widthStr
         escapingHTMLAttributeValue: NO];
    }
    if (heightStr != nil)
    {
      [response _appendTagAttribute: @"height"
                              value: heightStr
         escapingHTMLAttributeValue: NO];
    }
  }
  else
  {
    NSString *message 
    = [resourcemanager errorMessageUrlForResourceNamed: fileNameValue
                                           inFramework: frameworkName];
    [response _appendTagAttribute:@"src"
                            value: message
       escapingHTMLAttributeValue:NO];
  }
}

// used from GSWActiveImage
// _appendImageSizetoResponseInContext

+ (void) _appendImageSizetoResponse:(GSWResponse *) response
                          inContext:(GSWContext *) context
                              width:(GSWAssociation *) width
                             height:(GSWAssociation *) height
{
  GSWComponent * component = GSWContext_component(context);
  NSString     * widthValue = nil;
  NSString     * heightValue = nil;

  if (width) {  
    widthValue = [[width valueInComponent:component] description];
  }
  if (height) {  
    heightValue = [[height valueInComponent:component] description];
  }
   
  if (widthValue != nil) {
    [response _appendTagAttribute: @"width"
                            value: widthValue
       escapingHTMLAttributeValue: NO];
  }
  if (heightValue != nil) {
    [response _appendTagAttribute: @"height"
                            value: heightValue
       escapingHTMLAttributeValue: NO];
  }
}

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

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
// do nothing!
}

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
