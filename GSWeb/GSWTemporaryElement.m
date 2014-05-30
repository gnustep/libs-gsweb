/** GSWTemporaryElement.m - <title>GSWeb: Class GSWTemporaryElement</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
   $Revision$
   $Date$
   $Id$
   
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

#include "config.h"

#include "GSWeb.h"
#include "GSWPrivate.h"

//====================================================================
@implementation GSWTemporaryElement

//--------------------------------------------------------------------
+(GSWTemporaryElement*)temporaryElement
{
  return [[[self alloc]init]autorelease];
}

//--------------------------------------------------------------------
+(GSWTemporaryElement*)temporaryElementOfType:(GSWHTMLRawParserTagType)tagType
                               withProperties:(NSDictionary*)properties
                                 templateInfo:(NSString*)templateInfo
                                       parent:(GSWTemporaryElement*)parent
{
  return [[[self alloc]initWithType:tagType
                       withProperties:properties
                       templateInfo:templateInfo
                       parent:parent]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithType:(GSWHTMLRawParserTagType)tagType
   withProperties:(NSDictionary*)properties
     templateInfo:(NSString*)templateInfo
           parent:(GSWTemporaryElement*)parent
{
  if ((self=[self init]))
    {
      _parent=parent;
      ASSIGNCOPY(_properties,properties);
      ASSIGNCOPY(_templateInfo,templateInfo);
    };

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_properties);
  DESTROY(_children);
  DESTROY(_templateInfo);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p: properties=%@ parent=%p children count=%"PRIuPTR" templateInfo=%@>",
                   object_getClassName(self),
                   (void*)self,
                   _properties,
                   _parent,
                   [_children count],
                   _templateInfo];
};


//--------------------------------------------------------------------
/** adds element to children **/
-(void)addChildElement:(GSWElement*)element
{

  if (!_children)
    _children=[NSMutableArray new];
  [_children addObject:element];

};

//--------------------------------------------------------------------
/** Returns parent element **/
-(GSWTemporaryElement*)parentElement
{
  return _parent;
};

//--------------------------------------------------------------------
/** Returns template information **/
-(NSString*)templateInfo
{
  return _templateInfo;
}

//--------------------------------------------------------------------
/** Create a GSWElement representing child elements tree
**/
-(GSWElement*)template
{
  GSWElement* template = nil;
  NSMutableArray* elementChildren=nil;
  int childrenCount=0;

  // Is there children ?
  childrenCount=[_children count];
  if (childrenCount>0)
    {
      // Only one ? So we don't have to make 'complex' processing
      if (childrenCount==1)
        {
          elementChildren=_children;
        }
      else
        {
          // More than one child: try to concatenate BareStrings
          NSMutableString* bareStringText=nil;
          int i=0;
	  IMP oaiIMP=NULL;
          for(i=0;i<childrenCount;i++)
            {
              GSWElement* element=GSWeb_objectAtIndexWithImpPtr(_children,&oaiIMP,i);
              if ([element isKindOfClass:[GSWHTMLBareString class]])// Concatenate BareStrings
                {
                  if (bareStringText)
                    {
                      [bareStringText appendString:[(GSWHTMLBareString*)element string]];
                      element=nil;
                    }
                  else if (i+1<childrenCount
                           && [GSWeb_objectAtIndexWithImpPtr(_children,&oaiIMP,i+1)
							    isKindOfClass:[GSWHTMLBareString class]])
                    {
                      bareStringText=[NSMutableString stringWithString:[(GSWHTMLBareString*)element string]];
                      element=nil;
                    };
                }
              else
                {
                  if([bareStringText length]>0)
                    {
                      GSWHTMLBareString* bareString = [GSWHTMLBareString elementWithString:bareStringText];
                      [bareStringText setString:@""];
                      if (!elementChildren)
                        elementChildren=(NSMutableArray*)[NSMutableArray array];
                      [elementChildren addObject:bareString];
                    };
                };
              if (element)
                {
                  if (!elementChildren)
                    elementChildren=(NSMutableArray*)[NSMutableArray array];
                  [elementChildren addObject:element];
                };
            };
        };

      if ([elementChildren count]==1)
        {
          template=[elementChildren lastObject];
        } 
      else
        {
          template=[GSWHTMLStaticGroup elementWithContentElements:elementChildren];
        };
    };

  return template;
}

//--------------------------------------------------------------------
/** Return Element Name, taken from properties
nil if none is found
**/
-(NSString*)name
{
  NSString* name=nil;


  name=[_properties objectForKey:@"name"];


  return name;
};

//--------------------------------------------------------------------
/** Returns real dynamic element using declarations to find element type 
Raise an exception if element name is not found or if no declaration is 
found for that element
**/
-(GSWElement*)dynamicElementWithDeclarations:(NSDictionary*)declarations
                                   languages:(NSArray*)languages
{
  GSWElement* element=nil;
  GSWElement* template = nil;
  NSString* name=nil;
  GSWDeclaration* elementDeclaration=nil;

  // First, get children template
  template = [self template];

  // Get element name
  name=[self name];

  if (!name)
    {
      [GSWDeclarationFormatException raise:GSWDFEMissingElementName
                                     format:@"No element name for dynamic tag %@. %@",
                                     self,_templateInfo];
    }
  else
    {
      elementDeclaration = [declarations objectForKey:name];
      
      if (!elementDeclaration)
        {
          [GSWDeclarationFormatException raise:GSWDFEMissingDeclarationForElement
                                         format:@"No declaration for element named '%@'. Declarations: %@. %@",
                                         name,[declarations allKeys],_templateInfo];
        }
      else
        {
          element=[self _elementWithDeclaration:elementDeclaration
                        name:name
                        properties:_properties
                        template:template
                        languages:languages];
        };
    };


  return element;
}

//--------------------------------------------------------------------
/** Returns real dynamic element using declaration
May raise exception if element can't be created
**/
-(GSWElement*)_elementWithDeclaration:(GSWDeclaration*)declaration
                                 name:(NSString*)name
                           properties:(NSDictionary*)properties
                             template:(GSWElement*)template
                            languages:(NSArray*)languages
{
  GSWElement* element = nil;

  if (!declaration)
    {
      [GSWDeclarationFormatException raise:GSWDFEMissingDeclarationForElement
                                     format:@"No declaration for element named '%@'. %@",
                                     name,_templateInfo];
    }
  else
    {
      Class elementClass = Nil;
      NSString* elementType=[declaration type];

      if (elementType != nil) {
        elementClass = NSClassFromString(elementType);
      }
      
      if ((elementType == nil) || (elementClass == Nil)) //[elementType length]==0
        {
          [GSWDeclarationFormatException raise:GSWDFEMissingClassNameForElement
                                         format:@"No class name for element named '%@' with declaration: %@. %@",
                                         name,declaration,_templateInfo];
        }
      else
        {
          NSDictionary* associations = nil;

          associations=[declaration associations];
          if ([properties count]>0)
            {
              NSEnumerator* _propertiesEnum = [properties keyEnumerator];
              NSMutableDictionary* addedAssoc=nil;
              NSString* key=nil;
              NSString* value=nil;
              while ((key = [_propertiesEnum nextObject]))
                {
                  if (![key isEqualToString:@"name"] && ![associations objectForKey:key])
                    {
                      if (!addedAssoc)
                        addedAssoc=(NSMutableDictionary*)[NSMutableDictionary dictionary];
                      value=[properties objectForKey:key];
                      [addedAssoc setObject:[GSWAssociation associationWithValue:value]
                                  forKey:key];
                    };
                };
              if (addedAssoc)
                {
                  associations=[associations dictionaryByAddingEntriesFromDictionary:addedAssoc];
                };
            };

          // Create element
          element=[GSWApp dynamicElementWithName:elementType
                          associations:associations
                          template:template
                          languages:languages];
          if (element)
            {
              [element setDeclarationName:[declaration name]];
            }
          else
            {
              [GSWDeclarationFormatException raise:GSWDFEElementCreationFailed
                                             format:@"Can't create element named '%@' with declaration: %@. %@",
                                             name,declaration,_templateInfo];
            };
        };
    };

  return element;
}


@end

