/** GSWCheckBoxList.m - <title>GSWeb: Class GSWCheckBoxList</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

/**
Bindings

	list		Array of objects that the dynamic element iterate through.

        index		On each iteration the element put the current index in this binding

        item		On each iteration the element take the item at the current index and put it in this binding

        displayString  	String to display for each check box.

        value		Value for the INPUT tag for each check box

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selections	Array of selected objects (used to pre-check checkboxes and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        selectionValues	Array of selected values (used to pre-check checkboxes and modified to reflect user choices)
        			It contains evaluated values binding !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString
**/

//====================================================================
@implementation GSWCheckBoxList

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements_=%@",aName,associations,elements_);
  _defaultEscapeHTML=1;
  [tmpAssociations removeObjectForKey:list__Key];
  [tmpAssociations removeObjectForKey:item__Key];
  [tmpAssociations removeObjectForKey:index__Key];
  [tmpAssociations removeObjectForKey:prefix__Key];
  [tmpAssociations removeObjectForKey:suffix__Key];
  [tmpAssociations removeObjectForKey:selections__Key];
  [tmpAssociations removeObjectForKey:displayString__Key];
  [tmpAssociations removeObjectForKey:escapeHTML__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      _list = [[associations objectForKey:list__Key
                             withDefaultObject:[_list autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"list=%@",_list);

      _item = [[associations objectForKey:item__Key
                             withDefaultObject:[_item autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"item=%@",_item);
      if (_item && ![_item isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBoxList",@"'item' parameter must be settable");
        };

      _value = [[associations objectForKey:value__Key
                              withDefaultObject:[_value autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"value=%@",_value);

      _index = [[associations objectForKey:index__Key
                              withDefaultObject:[_index autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"index=%@",_index);
      if (_index && ![_index isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBoxList",@"'index' parameter must be settable");
        };
	  
      _prefix = [[associations objectForKey:prefix__Key
                               withDefaultObject:[_prefix autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"prefix=%@",_prefix);

      _suffix = [[associations objectForKey:suffix__Key
                               withDefaultObject:[_suffix autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"suffix=%@",_suffix);

      _selections = [[associations objectForKey:selections__Key
                                   withDefaultObject:[_selections autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"selections=%@",_selections);
      if (_selections && ![_selections isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBoxList",@"'selections' parameter must be settable");
        };
      
      if (!WOStrictFlag)
        {
          _selectionValues=[[associations objectForKey:selectionValues__Key
                                          withDefaultObject:[_selectionValues autorelease]] retain];
          if (_selectionValues && ![_selectionValues isValueSettable])
            {
              ExceptionRaise0(@"GSWCheckBoxList",@"'selectionValues' parameter must be settable");
            };
        };

      _displayString = [[associations objectForKey:displayString__Key
                                      withDefaultObject:[_displayString autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"displayString=%@",_displayString);
	  
      _escapeHTML = [[associations objectForKey:escapeHTML__Key
                                   withDefaultObject:[_escapeHTML autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"escapeHTML=%@",_escapeHTML);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_selections);
  DESTROY(_selectionValues);//GSWeb Only
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);
  DESTROY(_itemDisabled);
  DESTROY(_escapeHTML);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"INPUT";
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStartC("GSWCheckBoxList");
  [self _slowTakeValuesFromRequest:request
        inContext:context];
  LOGObjectFnStopC("GSWCheckBoxList");
};

//-----------------------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
			inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBoxList");

  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
	{
	  GSWComponent* component=[context component];
	  NSArray* listValue=nil; // _list value
	  NSMutableArray* selectionsValue=nil;
	  NSMutableArray* selectionValuesValue=nil;
	  NSString* name=nil;
	  NSArray* formValues=nil;
	  id valueValue=nil; // _value value
	  NSString* valueValueString=nil; // _value value
          id itemValue=nil;  // _item value
	  int i=0;

	  name=[self nameInContext:context];
	  NSDebugMLLog(@"gswdync",@"name=%@",name);

	  formValues=[request formValuesForKey:name];
	  NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);
	  NSDebugMLLog(@"gswdync",@"formValues class=%@",[formValues valueForKey:@"class"]);

	  listValue=[_list valueInComponent:component];
	  NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
		    @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
		    _list,
		    listValue,
		    [listValue class]);
	  NSDebugMLLog(@"gswdync",@"listValue=%@",listValue);

	  for(i=0;i<[listValue count];i++)
	    {
	      NSDebugMLLog(@"gswdync",@"item=%@",_item);
	      NSDebugMLLog(@"gswdync",@"index=%@",_index);

              itemValue=[listValue objectAtIndex:i];
	      if (_item)
		[_item setValue:itemValue
                       inComponent:component];

	      if (_index)
		[_index setValue:[NSNumber numberWithShort:i]
                        inComponent:component];
              
	      NSDebugMLLog(@"gswdync",@"value=%@",_value);              
              if (_value)  	// Binded Value          
                valueValue = [_value valueInComponent:component];
              else		// Auto Value
                valueValue = [NSNumber numberWithInt:i]; 
              valueValueString=[NSString stringWithFormat:@"%@",valueValue];
	      NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
              
	      if (valueValue)
		{
                  // we compare (with object equality not pointer equality) 
		  BOOL found=[formValues containsObject:valueValueString];

		  NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
		  if (found)
		    {
                      if (_selections)
                        {
                          if (!selectionsValue)
                            selectionsValue=[NSMutableArray array];
                          
                          // We add list object
                          [selectionsValue addObject:itemValue];
                        };

                      if (_selectionValues)
                        {
                          if (!selectionValuesValue)
                            selectionValuesValue=[NSMutableArray array];
                          
                          // We add list object
                          [selectionValuesValue addObject:valueValue];
                        };
		    };
		};
	    };
	  NSDebugMLLog(@"gswdync",@"component=%@",component);
	  NSDebugMLLog(@"gswdync",@"selectionsValue=%d",selectionsValue);
	  NSDebugMLLog(@"gswdync",@"selections=%@",_selections);
	  GSWLogAssertGood(component);
          NS_DURING
            {
              [_selections setValue:selectionsValue
                           inComponent:component];
            };
          NS_HANDLER
            {
              LOGException(@"GSWCheckBoxList _selections=%@ selectionsValue=%@ exception=%@",
                           _selections,selectionsValue,localException);
              if (WOStrictFlag)
                {
                  [localException raise];
                }
              else
                {
                  [self handleValidationException:localException
                        inContext:context];
                };
            }
          NS_ENDHANDLER;

          if (!WOStrictFlag && _selectionValues)
            {
              NS_DURING
                {
                  [_selectionValues setValue:selectionValuesValue
                                    inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWCheckBoxList _selectionValues=%@ selectionValuesValue=%@ exception=%@",
                               _selectionValues,selectionValuesValue,localException);
                  if (WOStrictFlag)
                    {
                      [localException raise];
                    }
                  else
                    {
                      [self handleValidationException:localException
                            inContext:context];
                    };
                }
              NS_ENDHANDLER;
            };
	};
    };
  LOGObjectFnStopC("GSWCheckBoxList");
};

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  LOGObjectFnStartC("GSWCheckBoxList");
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStopC("GSWCheckBoxList");
};
//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  NSString* name=nil;
  GSWComponent* component=nil;
  NSArray* selectionsValue=nil;
  NSArray* selectionValuesValue=nil;

  LOGObjectFnStartC("GSWCheckBoxList");

  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  name=[self nameInContext:context];
  component=[context component];
  selectionsValue=[_selections valueInComponent:component];
  if (selectionsValue && ![selectionsValue isKindOfClass:[NSArray class]])
    {
      ExceptionRaise(@"GSWCheckBoxList",
		     @"GSWCheckBoxList: selections is not a NSArray: %@ %@",
		     selectionsValue,
		     [selectionsValue class]);
    }
  else
    {
      selectionValuesValue=[_selectionValues valueInComponent:component];
      if (selectionValuesValue && ![selectionValuesValue isKindOfClass:[NSArray class]])
        {
          ExceptionRaise(@"GSWCheckBoxList",
                         @"GSWCheckBoxList: selectionValues is not a NSArray: %@ %@",
                         selectionValuesValue,
                         [selectionValuesValue class]);
        }
      else
        {
          int i=0;
          id displayStringValue=nil;
          id prefixValue=nil;
          id suffixValue=nil;
          id valueValue=nil;
          id itemValue=nil;
          BOOL disabledInContext=NO;
          NSArray* listValue=[_list valueInComponent:component];
          
          NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                    @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                    _list,
                    listValue,
                    [listValue class]);
          
          for(i=0;i<[listValue count];i++)
            {              
              BOOL isEqual=NO;

              disabledInContext=[self disabledInContext:context];
              
              itemValue=[listValue objectAtIndex:i];
              [_item setValue:itemValue
                     inComponent:component];
              
              prefixValue=[_prefix valueInComponent:component];
              suffixValue=[_suffix valueInComponent:component];
              
              [_index setValue:[NSNumber numberWithShort:i]
                      inComponent:component];
              
              displayStringValue=[_displayString valueInComponent:component];
              
              [response appendContentString:@"<INPUT NAME=\""];
              [response appendContentString:name];
              
              [response appendContentString:@"\" TYPE=checkbox VALUE=\""];
              
              NSDebugMLLog(@"gswdync",@"_value (class: %@): %@",[_value class],_value);
              // Value property of the INPUT tag
              if (_value)  	// Binded Value          
                valueValue = [_value valueInComponent:component];
              else		// Auto Value
                valueValue = [NSNumber numberWithInt:i]; 
              NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
              
              [response appendContentHTMLAttributeValue:valueValue];
              [response appendContentCharacter:'"'];
              
              NSDebugMLLog(@"gswdync",@"selectionsValue=%@",selectionsValue);
              NSDebugMLLog(@"gswdync",@"selectionsValue classes=%@",[selectionsValue valueForKey:@"class"]);
              NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
              NSDebugMLLog(@"gswdync",@"itemValue class=%@",[itemValue class]);
              if (_selections)
                {
                  // we compare (with object equality not pointer equality) on list object, not valueValue !
                  isEqual = [selectionsValue containsObject:itemValue];
                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                }

              NSDebugMLLog(@"gswdync",@"selectionValuesValue=%@",selectionValuesValue);
              NSDebugMLLog(@"gswdync",@"selectionValuesValue classes=%@",[selectionValuesValue valueForKey:@"class"]);
              NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
              NSDebugMLLog(@"gswdync",@"valueValue class=%@",[valueValue class]);
              if (isEqual==NO && _selectionValues)
                {
                  // we compare (with object equality not pointer equality) on valueValue !
                  isEqual = [selectionValuesValue containsObject:valueValue];
                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                }
              
              if(isEqual)
                [response appendContentString:@" CHECKED"];
              
              if (disabledInContext) 
                [response appendContentString:@" DISABLED"];
              
              [response appendContentCharacter:'>'];
              [response appendContentString:prefixValue];
              [response appendContentHTMLString:displayStringValue];
              [response appendContentString:suffixValue];
            };
        };
    };
  LOGObjectFnStopC("GSWCheckBoxList");
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListC)
-(BOOL)appendStringAtRight:(id)_unkwnon
               withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)appendStringAtLeft:(id)_unkwnon
              withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
