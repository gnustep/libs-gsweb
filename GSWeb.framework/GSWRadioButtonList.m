/** GSWRadioButtonList.m - <title>GSWeb: Class GSWRadioButtonList</title>

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

        displayString  	String to display for each radio button.

        value		Value for the INPUT tag for each radio button

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selection	Selected object (used to pre-check radio button and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectionValue	Selected value (used to pre-check radio button and modified to reflect user choice)
        			It contains evaluated value binding !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the radio button appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        isDisplayStringBefore If evaluated to yes, displayString is displayed before radio button
**/
//====================================================================
@implementation GSWRadioButtonList

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWRadioButtonList");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",
               aName,associations,elements);
  _defaultEscapeHTML=1;
  [tmpAssociations removeObjectForKey:list__Key];
  [tmpAssociations removeObjectForKey:item__Key];
  [tmpAssociations removeObjectForKey:index__Key];
  [tmpAssociations removeObjectForKey:selection__Key];
  if (!WOStrictFlag)
    [tmpAssociations removeObjectForKey:selectionValue__Key];
  [tmpAssociations removeObjectForKey:prefix__Key];
  [tmpAssociations removeObjectForKey:suffix__Key];
  [tmpAssociations removeObjectForKey:displayString__Key];
  [tmpAssociations removeObjectForKey:escapeHTML__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      _list=[[associations objectForKey:list__Key
                          withDefaultObject:[_list autorelease]] retain];
      _item=[[associations objectForKey:item__Key
                          withDefaultObject:[_item autorelease]] retain];
      if (_item && ![_item isValueSettable])
        {
          ExceptionRaise0(@"GSWRadioButtonList",@"'item' parameter must be settable");
        };
      _index=[[associations objectForKey:index__Key
                            withDefaultObject:[_index autorelease]] retain];
      if (_index && ![_index isValueSettable])
        {
          ExceptionRaise0(@"GSWRadioButtonList",@"'index' parameter must be settable");
        };
      
      _selection=[[associations objectForKey:selection__Key
                                withDefaultObject:[_selection autorelease]] retain];
      if (_selection && ![_selection isValueSettable])
        {
          ExceptionRaise0(@"GSWRadioButtonList",@"'selection' parameter must be settable");
        };
      if (!WOStrictFlag)
        {
          _selectionValue=[[associations objectForKey:selectionValue__Key
                                         withDefaultObject:[_selectionValue autorelease]] retain];
          if (_selectionValue && ![_selectionValue isValueSettable])
            {
              ExceptionRaise0(@"GSWRadioButtonList",@"'selectionValue' parameter must be settable");
            };
        };
      _prefix=[[associations objectForKey:prefix__Key
                             withDefaultObject:[_prefix autorelease]] retain];
      _suffix=[[associations objectForKey:suffix__Key
                             withDefaultObject:[_suffix autorelease]] retain];
      _displayString=[[associations objectForKey:displayString__Key
                                    withDefaultObject:[_displayString autorelease]] retain];

      if (!WOStrictFlag)
        {
          _isDisplayStringBefore=[[associations objectForKey:isDisplayStringBefore__Key
                                                withDefaultObject:[_isDisplayStringBefore autorelease]] retain];
        };
      _escapeHTML=[[associations objectForKey:escapeHTML__Key
                                 withDefaultObject:[_escapeHTML autorelease]] retain];
    };
  return self;
};

//-----------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_selection);
  DESTROY(_selectionValue);//GSWeb Only
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);
  DESTROY(_isDisplayStringBefore);//GSWeb Only
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
@implementation GSWRadioButtonList (GSWRadioButtonListA)

//-----------------------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStartC("GSWRadioButtonList");
  [self _slowTakeValuesFromRequest:request
        inContext:context];
  LOGObjectFnStopC("GSWRadioButtonList");
};

//-----------------------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWRadioButtonList");

  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
        {
          GSWComponent* component=[context component];
          NSArray* listValue=nil; // _list value
          NSString* name=nil;
          BOOL found=NO;
          id formValue=nil;
          id valueValue=nil; // _value value (or autoValue)
          id itemValue=nil; // _item value
          NSString* valueValueString=nil; // _value value as string
          id itemValueToSet=nil; // item value to set to _selection
          id valueValueToSet=nil; // valueValue  to set to _selectionValue
          int i=0;

          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);

          formValue=[request formValueForKey:name];
          NSDebugMLLog(@"gswdync",@"formValue=%@",formValue);

          listValue=[_list valueInComponent:component];
          NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                    @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                    _list,
                    listValue,
                    [listValue class]);
          NSDebugMLLog(@"gswdync",@"listValue=%@",listValue);

          for(i=0;i<[listValue count] && !found;i++)
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
                  BOOL isEqual=SBIsValueEqual(valueValueString,formValue);
                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));

                  if (isEqual)
                    {
                      itemValueToSet=itemValue;
                      valueValueToSet=valueValue;
                      found=YES;
                    };
                };
            };
          NSDebugMLLog(@"gswdync",@"component=%@",component);
          NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
          NSDebugMLLog(@"gswdync",@"selection=%@",_selection);
          GSWLogAssertGood(component);
          NS_DURING
            {
              [_selection setValue:itemValueToSet
                          inComponent:component];
            };
          NS_HANDLER
            {
              LOGException(@"GSWRadioButtonList _selection=%@ itemValueToSet=%@ exception=%@",
                           _selection,itemValueToSet,localException);
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
          if (!WOStrictFlag && _selectionValue)
            {
              NS_DURING
                {
                  [_selectionValue setValue:valueValueToSet
                                   inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWRadioButtonList _selectionValue=%@ valueValueToSet=%@ exception=%@",
                               _selectionValue,valueValueToSet,localException);
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
  LOGObjectFnStopC("GSWRadioButtonList");
};

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  LOGObjectFnStartC("GSWRadioButtonList");
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStopC("GSWRadioButtonList");
};

//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  BOOL disabledInContext=NO;
  NSString* name=nil;
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  id selectionValue=nil;
  id selectionValueValue=nil;
  int i=0;
  id displayStringValue=nil;
  BOOL isDisplayStringBefore=NO;
  id prefixValue=nil;
  id suffixValue=nil;
  id valueValue=nil; // _value value (or auto value)
  id itemValue=nil; // _item value
  LOGObjectFnStartC("GSWRadioButtonList");

  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  name=[self nameInContext:context];
  component=[context component];

  selectionValue=[_selection valueInComponent:component];
  selectionValueValue=[_selectionValue valueInComponent:component];

  listValue=[_list valueInComponent:component];
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

      if (_isDisplayStringBefore)
        isDisplayStringBefore=[self evaluateCondition:_isDisplayStringBefore
                                    inContext:context];

      displayStringValue=[_displayString valueInComponent:component];

      if (isDisplayStringBefore)
        [response appendContentHTMLString:displayStringValue];

      [response appendContentString:@"<INPUT NAME=\""];
      [response appendContentString:name];

      [response appendContentString:@"\" TYPE=radio VALUE=\""];

      NSDebugMLLog(@"gswdync",@"_value (class: %@): %@",[_value class],_value);
      // Value property of the INPUT tag
      if (_value)  	// Binded Value          
        valueValue = [_value valueInComponent:component];
      else		// Auto Value
        valueValue = [NSNumber numberWithInt:i];
      NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
      
      [response appendContentHTMLAttributeValue:valueValue];
      [response appendContentCharacter:'"'];

      NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
      NSDebugMLLog(@"gswdync",@"selectionValue class=%@",[selectionValue class]);
      NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
      NSDebugMLLog(@"gswdync",@"itemValue class=%@",[itemValue class]);
      if (selectionValue)
        {
          isEqual=SBIsValueEqual(itemValue,selectionValue);
          NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
        }

      NSDebugMLLog(@"gswdync",@"selectionValueValue=%@",selectionValueValue);
      NSDebugMLLog(@"gswdync",@"selectionValueValue class=%@",[selectionValueValue class]);
      NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
      NSDebugMLLog(@"gswdync",@"valueValue class=%@",[valueValue class]);
      if (isEqual==NO && selectionValueValue)
        {
          isEqual=SBIsValueEqual(valueValue,selectionValueValue);
          NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
        }

      if (isEqual)
        [response appendContentString:@" CHECKED"];

      if (disabledInContext)
        [response _appendContentAsciiString:@" DISABLED"];

      [response appendContentCharacter:'>'];
      [response appendContentString:prefixValue];
      if (!isDisplayStringBefore)
        [response appendContentHTMLString:displayStringValue];
      [response appendContentString:suffixValue];
    };
  LOGObjectFnStopC("GSWRadioButtonList");
};

@end

//====================================================================
@implementation GSWRadioButtonList (GSWRadioButtonListB)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)compactHTMLTags
{
  return NO;
};

@end
