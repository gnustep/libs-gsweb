/** GSWBrowser.m - <title>GSWeb: Class GSWBrowser</title>

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

        value		Value for each OPTION tag 

        selections	Array of selected objects (used to pre-select items and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        selectedValues	Array of pre selected values (not objects !)

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        size		show 'size' iems at one time. Default=5. Must be > 1

        multiple	multiple selection allowed
**/

//====================================================================
@implementation GSWBrowser

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  NSMutableDictionary* tmpAssociations=nil;
  LOGObjectFnStartC("GSWBrowser");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",
               aName,associations,elements);
  tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  [tmpAssociations removeObjectForKey:list__Key];
  [tmpAssociations removeObjectForKey:item__Key];
  if (!WOStrictFlag)
    {
      [tmpAssociations removeObjectForKey:index__Key];
    };
  [tmpAssociations removeObjectForKey:displayString__Key];
  [tmpAssociations removeObjectForKey:selections__Key];
  if (!WOStrictFlag)
    [tmpAssociations removeObjectForKey:selectionValues__Key];
  [tmpAssociations removeObjectForKey:selectedValues__Key];
  [tmpAssociations removeObjectForKey:size__Key];
  [tmpAssociations removeObjectForKey:multiple__Key];
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
          ExceptionRaise0(@"GSWBrowser",@"'item' parameter must be settable");
        };

      if (!WOStrictFlag)
        {
          _index = [[associations objectForKey:index__Key
                                  withDefaultObject:[_index autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"index=%@",_index);
          if (_index && ![_index isValueSettable])
            {
              ExceptionRaise0(@"GSWBrowser",@"'index' parameter must be settable");
            };
        };

      _displayString=[[associations objectForKey:displayString__Key
                                    withDefaultObject:[_displayString autorelease]] retain];
      _selections=[[associations objectForKey:selections__Key
                                 withDefaultObject:[_selections autorelease]] retain];
      if (_selections && ![_selections isValueSettable])
        {
          ExceptionRaise0(@"GSWBrowser",@"'selections' parameter must be settable");
        };

      if (!WOStrictFlag)
        {
          _selectionValues=[[associations objectForKey:selectionValues__Key
                                          withDefaultObject:[_selectionValues autorelease]] retain];
          if (_selectionValues && ![_selectionValues isValueSettable])
            {
              ExceptionRaise0(@"GSWBrowser",@"'selectionValues' parameter must be settable");
            };
        };
      
      _selectedValues=[[associations objectForKey:selectedValues__Key
                                     withDefaultObject:[_selectedValues autorelease]] retain];
      _size=[[associations objectForKey:size__Key
                           withDefaultObject:[_size autorelease]] retain];
      _multiple=[[associations objectForKey:multiple__Key
                               withDefaultObject:[_multiple autorelease]] retain];
      _escapeHTML=[[associations objectForKey:escapeHTML__Key
                                 withDefaultObject:[_escapeHTML autorelease]] retain];
    };
  LOGObjectFnStopC("GSWBrowser");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_displayString);
  DESTROY(_selections);
  DESTROY(_selectionValues);
  DESTROY(_selectedValues);
  DESTROY(_size);
  DESTROY(_multiple);
  DESTROY(_escapeHTML);
  [super dealloc];
};

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
  return @"SELECT";
};

@end

//====================================================================
@implementation GSWBrowser (GSWBrowserA)

/*
 On WO it looks like that when value is not binded:

 <SELECT name="4.2.7" size=5 multiple>
 <OPTION value="0">blau</OPTION>
 <OPTION value="1">braun</OPTION>
 <OPTION selected value="2">gruen</OPTION>
 <OPTION value="3">marineblau</OPTION>
 <OPTION value="4">schwarz</OPTION>
 <OPTION value="5">silber</OPTION>
 <OPTION value="6">weiss</OPTION></SELECT>

 */

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  id selectionsValue=nil;
  id selectedValuesValue=nil;
  id valueValue=nil;
  id itemValue=nil;
  id displayStringValue=nil;
  BOOL escapeHTMLBoolValue=YES;
  id escapeHTMLValue=nil;
  int i=0;
  BOOL inOptGroup=NO;
#ifndef ENABLE_OPTGROUP
  BOOL optGroupLabel=NO;
#endif
  LOGObjectFnStartC("GSWBrowser");

  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  component=[context component];

  [super appendToResponse:response
         inContext:context];

  listValue=[_list valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"listValue=%@",listValue);
  NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
            @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
            _list,
            listValue,
            [listValue class]);

  selectionsValue=[_selections valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"selections=%@",_selections);
  NSDebugMLLog(@"gswdync",@"selectionsValue=%@",selectionsValue);

  selectedValuesValue=[_selectedValues valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"selectedValues=%@",_selectedValues);
  NSDebugMLLog(@"gswdync",@"selectedValuesValue=%@",selectedValuesValue);

  if (_escapeHTML)
    {
      escapeHTMLValue=[_escapeHTML valueInComponent:component];
      escapeHTMLBoolValue=boolValueFor(escapeHTMLValue);
    };

  for(i=0;i<[listValue count];i++)
    {
      NSDebugMLLog(@"gswdync",@"inOptGroup=%s",(inOptGroup ? "YES" : "NO"));
      itemValue=[listValue objectAtIndex:i];
      if (_item)
        [_item setValue:itemValue
               inComponent:component];
      NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);

      if (_index)
        [_index setValue:[NSNumber numberWithShort:i]
                inComponent:component];
      
      if (itemValue)
        {
          NSDebugMLLog(@"gswdync",@"_value (class: %@): %@",[_value class],_value);
          // Value property of the INPUT tag
          if (_value)  	// Binded Value          
            valueValue = [_value valueInComponent:component];
          else		// Auto Value
            valueValue = [NSNumber numberWithInt:i];
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);

          if (valueValue)
            {
              BOOL isEqual=NO;

              NSDebugMLLog0(@"gswdync",@"Adding OPTION");
              [response _appendContentAsciiString:@"\n<OPTION"];

              NSDebugMLLog(@"gswdync",@"selectionsValue=%@",selectionsValue);
              NSDebugMLLog(@"gswdync",@"selectionsValue classes=%@",[selectionsValue valueForKey:@"class"]);
              NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
              NSDebugMLLog(@"gswdync",@"itemValue class=%@",[itemValue class]);
              if (selectionsValue)
                {
                  isEqual = [selectionsValue containsObject:itemValue];
                };
              if (isEqual == NO && _selectedValues)
                {
                  // selected values is selections but on valueValue not itemValue
                  isEqual = [selectionsValue containsObject:valueValue];
                };

              if (isEqual)
                {
                  [response appendContentCharacter:' '];
                  [response _appendContentAsciiString:@"selected"];
                };

              [response _appendContentAsciiString:@" value=\""];
              [response _appendContentAsciiString:valueValue];
              [response appendContentCharacter:'"'];

              [response appendContentCharacter:'>'];
            };
          displayStringValue=nil;
          if (_displayString)
            {
              NSDebugMLLog(@"gswdync",@"displayString=%@",_displayString);
              displayStringValue=[_displayString valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"displayStringValue=%@",displayStringValue);
            };

          if (displayStringValue)
            {
              if (!valueValue)
                {
                  if (inOptGroup)
                    {
                      NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
#ifdef ENABLE_OPTGROUP
                      [response _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
                      inOptGroup=NO;
                    };
                  NSDebugMLLog0(@"gswdync",@"Adding OPTGROUP");
#ifdef ENABLE_OPTGROUP
                  [response _appendContentAsciiString:@"\n<OPTGROUP label=\""];
#else
#if 0
                  [response _appendContentAsciiString:@"\n<OPTION>-- "];
                  optGroupLabel=YES;
#else
                  [response _appendContentAsciiString:@"\n<OPTION>"];
#endif
                  optGroupLabel=YES;
#endif
                  inOptGroup=YES;
                };
              //<OPTGROUP label="PortMaster 3">
              
              if (escapeHTMLBoolValue)
                displayStringValue=[GSWResponse stringByEscapingHTMLString:displayStringValue];
              NSDebugMLLog(@"gswdync",@"displayStringValue=%@",displayStringValue);
#ifndef ENABLE_OPTGROUP
              if (optGroupLabel)
                {
                  displayStringValue=[NSString stringWithFormat:@"%@ --",displayStringValue];
                };
#endif
              [response appendContentHTMLString:displayStringValue];
            };
          if (valueValue)
            {
              // K2- No /OPTION TAG
              //[response _appendContentAsciiString:@"</OPTION>"];
            }
          else
            {
              NSDebugMLLog0(@"gswdync",@"Adding > or </OPTION>");
#ifdef ENABLE_OPTGROUP
              [response _appendContentAsciiString:@"\">"];
#else
              if (optGroupLabel)
                {
                  //[response _appendContentAsciiString:@"</OPTION>"];
                  optGroupLabel=NO;
                };
#endif
            };
        };
    };
  if (inOptGroup)
    {
#ifdef ENABLE_OPTGROUP
      NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
      [response _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
      inOptGroup=NO;
    };
  [response _appendContentAsciiString:@"</SELECT>"];
  LOGObjectFnStopC("GSWBrowser");
};

//-------------------------------------------------------------------- 

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStartC("GSWPopUpButton");
  [self _slowTakeValuesFromRequest:request
		inContext:context];
  LOGObjectFnStopC("GSWPopUpButton");
};

//-------------------------------------------------------------------- 
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  //OK
  BOOL disabledValue=NO;

  LOGObjectFnStartC("GSWPopUpButton");

  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      BOOL wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          BOOL isMultiple=NO;
	  NSMutableArray* selectionsValue=nil;
	  NSMutableArray* selectionValuesValue=nil;
          GSWComponent* component=nil;
          NSArray* listValue=nil;
          id valueValue=nil;
          NSString* valueValueString=nil;
          id itemValue=nil;
          NSString* name=nil;
          NSArray* formValues=nil;
          component=[context component];
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          if (_multiple)
            {
              id multipleValue=[_multiple valueInComponent:component];
              isMultiple=boolValueFor(multipleValue);
            };
          formValues=[request formValuesForKey:name];
          NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);

          //NSLog(@"formValues=%@",formValues);
          //NSLog(@"formValues class=%@",[formValues class]);
          
          if (formValues && [formValues count])
            {
              BOOL found=NO;
              int i=0;

              listValue=[_list valueInComponent:component];
              
              NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                        @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                        _list,
                        listValue,
                        [listValue class]);
              for(i=0;(!found || isMultiple) && i<[listValue count];i++)
                {
                  itemValue=[listValue objectAtIndex:i];
                  NSDebugMLLog(@"gswdync",@"_itemValue=%@",itemValue);
                  NSDebugMLLog(@"gswdync",@"item=%@",_item);

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
                      found=[formValues containsObject:valueValueString];
                      
                      NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
                      if (found)
                        {
                          // We add list object
                          if (_selections)
                            {
                              if (!selectionsValue)
                                selectionsValue=[NSMutableArray array];
                              
                              [selectionsValue addObject:itemValue];
                            };

                          // We add valueValue
                          if (_selectionValues)
                            {
                              if (!selectionValuesValue)
                                selectionValuesValue=[NSMutableArray array];
                              
                              [selectionValuesValue addObject:valueValue];
                            };
                        };
                    };
                };
              NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
            };              

          if (_selections)
            {
              NS_DURING
                {
                  [_selections setValue:selectionsValue
                               inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWBrowser _selections=%@ itemValueToSet=%@ exception=%@",
                               _selections,itemValueToSet,localException);
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
          if (!WOStrictFlag && _selectionValues)
            {
              NS_DURING
                {
                  [_selectionValues setValue:selectionValuesValue
                                    inComponent:component];
                };
              NS_HANDLER
                {
                  [self handleValidationException:localException
                        inContext:context];
                }
              NS_ENDHANDLER;
            };
        };
    };
  LOGObjectFnStopC("GSWPopUpButton");
};

//-------------------------------------------------------------------- 
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//-------------------------------------------------------------------- 
@end

//====================================================================
@implementation GSWBrowser (GSWBrowserB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  BOOL isMultiple=NO;
  id sizeValue=nil;
  GSWComponent* component=nil;
  LOGObjectFnStartC("GSWPopUpButton");

  [super appendGSWebObjectsAssociationsToResponse:response
         inContext:context];

  component=[context component];

  if (_size)
    sizeValue=[_size valueInComponent:component];
  else
    sizeValue=@"5"; //Default is 5

  [response _appendContentAsciiString:@" SIZE="];
  [response _appendContentAsciiString:sizeValue];

  if (_multiple)
  {
    id multipleValue=nil;
    multipleValue=[_multiple valueInComponent:component];
    isMultiple=boolValueFor(multipleValue);

    if (isMultiple)
      [response _appendContentAsciiString:@" MULTIPLE"];
  };
//  [response _appendContentAsciiString:@">"];
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context
{
  //Does nothing because value is only printed in OPTION tag
};

//--------------------------------------------------------------------

@end

//====================================================================
@implementation GSWBrowser (GSWBrowserC)
-(BOOL)appendStringAtRight:(id)_unkwnon
               withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
@end
