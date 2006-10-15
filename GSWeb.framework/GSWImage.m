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
                   object_get_class_name(self),
                   (void*)self];
};
 
 
// GSWImage._appendFilenameToResponseInContext(woresponse, wocontext, _framework, _filename, _width, _height);



+ (void) _appendFilenameToResponse:(GSWResponse *)   response
                         inContext:(GSWContext *)    context
                         framework:(GSWAssociation*) framework
                          filename:(GSWAssociation*) filename
                             width:(GSWAssociation*) width 
                            height:(GSWAssociation*) height
{
  id widthValue = nil;
  id heightValue = nil;
  BOOL hasNoWidth = NO;
  BOOL hasNoHeight = NO;

  GSWResourceManager * resourcemanager = [GSWApp resourceManager];

  GSWComponent * component = GSWContext_component(context);
  
  NSString* fileNameValue = [_filename valueInComponent:component];

  NSString * frameworkName = [self _frameworkNameForAssociation: _framework 
                                                    inComponent: component];

  NSString * resourceURL = [context _urlForResourceNamed:frameworkName inFramework: frameworkName];

  if (resourceURL != nil) {
    NSString * widthStr = nil;
    NSString * heightStr = nil;
    if (width != nil || height != nil) {
      if (width != nil) {
        widthValue = [width valueInComponent:component];
        widthStr = widthValue != nil ? widthValue : nil;        // stringValue?
        hasNoWidth = (widthStr == nil || [widthStr isEqual:@"*"]);
      }
      if (height != nil) {
        heightValue = [height valueInComponent:component];
        heightStr = heightValue != nil ? heightValue : nil;    // stringValue?
        hasNoHeight = (heightStr == nil || [heightStr isEqual:@"*"]);
      }
    } else {
      hasNoWidth = YES;
      hasNoHeight = YES;
      // do we really need that log? dw. 
      // NSLog("%@: No height or width information provided for '%@'. If possible, this information should be provided for best performance.", [self class], fileNameValue);
    }
    // GSWeb does not have that jet.
//    
//    if (hasNoWidth || hasNoHeight) {
//      GSWImageInfo * imageinfo = [resourcemanager _imageInfoForUrl: resourceURL
//                                                          fileName: fileNameValue
//                                                         framework: frameworkName
//                                                         languages: [context _languages]]);
//      if (imageinfo != nil) {
//        if (hasNoWidth)
//        {
//          widthStr = imageinfo.widthString();
//        }
//        if (hasNoHeight)
//        {
//          heightStr = imageinfo.heightString();
//        }
//      } else
//      {
//        NSLog("%@: could not get height/width information for image at '%@/%@/%@'", 
//                [self class], resourceURL, fileNameValue, frameworkName);
//      }
//    }

    [response _appendTagAttribute: @"src"
                            value: resourceURL
       escapingHTMLAttributeValue: NO];

    if (widthStr != nil) {
      [response _appendTagAttribute: @"width"
                              value: widthStr
         escapingHTMLAttributeValue: NO];
    }
    if (heightStr != nil) {
      [response _appendTagAttribute: @"height"
                              value: heightStr
         escapingHTMLAttributeValue: NO];
    }
  } else {
 
    [response _appendTagAttribute:@"src"
                            value:[resourcemanager errorMessageUrlForResourceNamed: fileNameValue
                                                                       inFramework: frameworkName]
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

- (void) _appendFilenameToResponse:(GSWResponse *) response
                         inContext:(GSWContext *) context
{
  id widthValue = nil;
  id heightValue = nil;
  BOOL hasNoWidth = NO;
  BOOL hasNoHeight = NO;

  GSWResourceManager * resourcemanager = [GSWApp resourceManager];

  GSWComponent * component = GSWContext_component(context);
  
  NSString* fileNameValue = [_filename valueInComponent:component];

  NSString * frameworkName = [self _frameworkNameForAssociation: _framework 
                                                    inComponent: component];

  NSString * resourceURL = [context _urlForResourceNamed:frameworkName inFramework: frameworkName];

  if (resourceURL != nil) {
    NSString * widthStr = nil;
    NSString * heightStr = nil;
    
    NSLog(@"%s resourceURL:%@",__PRETTY_FUNCTION__, resourceURL);
    
    if (_width != nil || _height != nil) {
      if (_width != nil) {
        widthValue = [_width valueInComponent:component];
        widthStr = widthValue != nil ? NSStringWithObject(widthValue) : nil;
        hasNoWidth = (widthStr == nil || [widthStr isEqual:@"*"]);
      }
      if (_height != nil) {
        heightValue = [_height valueInComponent:component];
        heightStr = heightValue != nil ? NSStringWithObject(heightValue) : nil;    // stringValue?
        hasNoHeight = (heightStr == nil || [heightStr isEqual:@"*"]);
      }
    } else {
      hasNoWidth = YES;
      hasNoHeight = YES;
      // do we really need that log? dw. 
      // NSLog("%@: No height or width information provided for '%@'. If possible, this information should be provided for best performance.", [self class], fileNameValue);
    }
    // GSWeb does not have that jet.
//    
//    if (hasNoWidth || hasNoHeight) {
//      GSWImageInfo * imageinfo = [resourcemanager _imageInfoForUrl: resourceURL
//                                                          fileName: fileNameValue
//                                                         framework: frameworkName
//                                                         languages: [context _languages]]);
//      if (imageinfo != nil) {
//        if (hasNoWidth)
//        {
//          widthStr = imageinfo.widthString();
//        }
//        if (hasNoHeight)
//        {
//          heightStr = imageinfo.heightString();
//        }
//      } else
//      {
//        NSLog("%@: could not get height/width information for image at '%@/%@/%@'", 
//                [self class], resourceURL, fileNameValue, frameworkName);
//      }
//    }

    [response _appendTagAttribute: @"src"
                            value: resourceURL
       escapingHTMLAttributeValue: NO];

    if (widthStr != nil) {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
                                                                    width__Key,
                                                                    widthStr,
                                                                    NO);
    }
    if (heightStr != nil) {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
                                                                    height__Key,
                                                                    heightStr,
                                                                    NO);
    }
  } else { // resourceURL is nil
 
     NSLog(@"%s resourceURL is nil self:%@",__PRETTY_FUNCTION__, self);

    [response _appendTagAttribute:@"src"
                            value:[resourcemanager errorMessageUrlForResourceNamed: fileNameValue
                                                                       inFramework: frameworkName]
       escapingHTMLAttributeValue:NO];
  }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
// do nothing!
}

@end
