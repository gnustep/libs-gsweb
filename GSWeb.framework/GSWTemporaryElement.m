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

RCS_ID("$Id$")

#include "GSWeb.h"

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
  LOGObjectFnStart();

  if ((self=[self init]))
    {
      _parent=parent;
      ASSIGNCOPY(_properties,properties);
      ASSIGNCOPY(_templateInfo,templateInfo);
    };

  LOGObjectFnStop();

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
  return [NSString stringWithFormat:@"<%s %p: properties=%@ parent=%p children count=%d templateInfo=%@>",
                   object_get_class_name(self),
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
  LOGObjectFnStart();

  if (!_children)
    _children=[NSMutableArray new];
  [_children addObject:element];

  LOGObjectFnStart();
};

//--------------------------------------------------------------------
/** Returns parent element **/
-(GSWTemporaryElement*)parentElement
{
  LOGObjectFnStart();

  LOGObjectFnStop();

  return _parent;
};

//--------------------------------------------------------------------
/** Returns template information **/
-(NSString*)templateInfo
{
  LOGObjectFnStart();

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"_children=%@",_children);

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

          for(i=0;i<childrenCount;i++)
            {
              GSWElement* element=[_children objectAtIndex:i];
              NSDebugMLog(@"element=%@",element);
              if ([element isKindOfClass:[GSWHTMLBareString class]])// Concatenate BareStrings
                {
                  NSDebugMLog(@"bareStringText=%@",bareStringText);
                  if (bareStringText)
                    {
                      [bareStringText appendString:[(GSWHTMLBareString*)element string]];
                      element=nil;
                    }
                  else if (i+1<childrenCount
                           && [[_children objectAtIndex:i+1] isKindOfClass:[GSWHTMLBareString class]])
                    {
                      bareStringText=[NSMutableString stringWithString:[(GSWHTMLBareString*)element string]];
                      element=nil;
                    };
                  NSDebugMLog(@"element=%@",element);
                }
              else
                {
                  if([bareStringText length]>0)
                    {
                      GSWHTMLBareString* bareString = [GSWHTMLBareString elementWithString:bareStringText];
                      [bareStringText setString:@""];
                      NSDebugMLog(@"bareString=%@",bareString);
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

      NSDebugMLog(@"elementChildren=%@",elementChildren);
      if ([elementChildren count]==1)
        {
          template=[elementChildren lastObject];
        } 
      else
        {
          template=[GSWHTMLStaticGroup elementWithContentElements:elementChildren];
        };
    };

  NSDebugMLog(@"template=%@",template);

  LOGObjectFnStop();

  return template;
}

//--------------------------------------------------------------------
/** Return Element Name, taken from properties
nil if none is found
**/
-(NSString*)name
{
  NSString* name=nil;

  LOGObjectFnStart();

  name=[_properties objectForKey:@"name"];
  NSDebugMLog(@"name=%@",name);
  NSDebugMLog(@"_properties=%@",_properties);

  LOGObjectFnStop();

  return name;
};

//--------------------------------------------------------------------
/** Returns real dynamic element usinf declarations to find element type 
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

  LOGObjectFnStart();

  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"declarations=%@",declarations);
  NSDebugMLog(@"languages=%@",languages);

  // First, get children template
  template = [self template];
  NSDebugMLog(@"template=%@",template);

  // Get element name
  name=[self name];
  NSDebugMLog(@"name=%@",name);

  if (!name)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No element name for dynamic tag %@. %@",
                   self,_templateInfo];
    }
  else
    {
      elementDeclaration = [declarations objectForKey:name];
      NSDebugMLog(@"elementDeclaration=%@",elementDeclaration);
      
      if (!elementDeclaration)
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"No declaration for element named '%@'. Declarations: %@. %@",
                       name,declarations,_templateInfo];
        }
      else
        {
          element=[self _elementWithDeclaration:elementDeclaration
                        name:name
                        properties:_properties
                        template:template
                        languages:languages];
          NSDebugMLog(@"element=%@",element);
        };
    };

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  NSDebugMLog(@"declaration=%@",declaration);
  NSDebugMLog(@"name=%@",name);
  NSDebugMLog(@"properties=%@",properties);
  NSDebugMLog(@"template=%@",template);

  if (!declaration)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No declaration for element named '%@'. %@",
                   name,_templateInfo];
    }
  else
    {
      NSString* elementType=[declaration type];
      NSDebugMLog(@"elementType=%@",elementType);

      if ([elementType length]==0)
        {
          [NSException raise:NSInvalidArgumentException 
                       format:@"No class name for named '%@' with declaration: %@. %@",
                       name,declaration,_templateInfo];
        }
      else
        {
          Class elementClass = NSClassFromString(elementType);

          NSDebugMLog(@"elementClass=%@",elementClass);

          NSDictionary* associations=[declaration associations];
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
                      NSDebugMLog(@"key=%@ value=%@",key,value);
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
          NSDebugMLog(@"element=%@",element);
          if (element)
            [element setDeclarationName:[declaration name]];
          else
            {
              [NSException raise:NSInvalidArgumentException 
                           format:@"Can't create element named '%@' with declaration: %@. %@",
                           name,declaration,_templateInfo];
            };
        };
    };

  NSDebugMLog(@"element=%@",element);

  LOGObjectFnStop();

  return element;
}


@end

