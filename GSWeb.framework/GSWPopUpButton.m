/** GSWPopUpButton.m - <title>GSWeb: Class GSWPopUpButton</title>

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

        displayString  	String to display for each item.

        value		Value for each OPTION tag 

        selection	Selected object (used to pre-select item and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectedValue	Array of pre selected values (not objects !)

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        noSelectionString	If binded, displayed as the first item. If selected, considered as 
        				an empty selection (selection is set to nil, selectionValue too)

**/

//====================================================================
@implementation GSWPopUpButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  NSMutableDictionary* tmpAssociations=nil;
  LOGObjectFnStartC("GSWPopUpButton");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ _elements=%@",
               aName,associations,elements);
  tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  [tmpAssociations removeObjectForKey:list__Key];
  [tmpAssociations removeObjectForKey:item__Key];
  if (!WOStrictFlag)
    {
      [tmpAssociations removeObjectForKey:count__Key];
      [tmpAssociations removeObjectForKey:index__Key];
    };
  [tmpAssociations removeObjectForKey:displayString__Key];
  [tmpAssociations removeObjectForKey:selection__Key];
  if (!WOStrictFlag)
    [tmpAssociations removeObjectForKey:selectionValue__Key];
  [tmpAssociations removeObjectForKey:selectedValue__Key];
  [tmpAssociations removeObjectForKey:noSelectionString__Key];
  [tmpAssociations removeObjectForKey:escapeHTML__Key];

  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      _list=[[associations objectForKey:list__Key
                           withDefaultObject:[_list autorelease]] retain];
      _item=[[associations objectForKey:item__Key
                           withDefaultObject:[_item autorelease]] retain];
      _displayString=[[associations objectForKey:displayString__Key
                                    withDefaultObject:[_displayString autorelease]] retain];
      _selection=[[associations objectForKey:selection__Key
                                withDefaultObject:[_selection autorelease]] retain];
      if (_selection && ![_selection isValueSettable])
        {
          ExceptionRaise0(@"GSWPopUpButton",@"'selection' parameter must be settable");
        };
      
      if (!WOStrictFlag)
        {
          _selectionValue=[[associations objectForKey:selectionValue__Key
                                         withDefaultObject:[_selectionValue autorelease]] retain];
          if (_selectionValue && ![_selectionValue isValueSettable])
            {
              ExceptionRaise0(@"GSWPopUpButton",@"'selectionValue' parameter must be settable");
            };
        };
      
      _selectedValue=[[associations objectForKey:selectedValue__Key
                                    withDefaultObject:[_selectedValue autorelease]] retain];
      _noSelectionString=[[associations objectForKey:noSelectionString__Key
                                        withDefaultObject:[_noSelectionString autorelease]] retain];
      _escapeHTML=[[associations objectForKey:escapeHTML__Key
                                 withDefaultObject:[_escapeHTML autorelease]] retain];

      if (!WOStrictFlag)
        {
          _count=[[associations objectForKey:count__Key
                                withDefaultObject:[_count autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"count=%@",_count);
          _index=[[associations objectForKey:index__Key
                                withDefaultObject:[_index autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"index=%@",_index);
          if (_index && ![_index isValueSettable])
            {
              ExceptionRaise0(@"GSWPopUpButton",@"'index' parameter must be settable");
            };
        };
    };
  LOGObjectFnStopC("GSWPopUpButton");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_displayString);
  DESTROY(_selection);
  DESTROY(_selectionValue);//GSWeb Only
  DESTROY(_selectedValue);
  DESTROY(_noSelectionString);
  DESTROY(_escapeHTML);
  DESTROY(_count);//GSWeb Only
  DESTROY(_index);//GSWeb Only
  [super dealloc];
};


//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"SELECT";
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

@end

//====================================================================

/*

 On WO it looks like that when value is not binded:

 <SELECT name="4.2.7">
 <OPTION value="0">blau</OPTION>
 <OPTION value="1">braun</OPTION>
 <OPTION selected value="2">gruen</OPTION>
 <OPTION value="3">marineblau</OPTION>
 <OPTION value="4">schwarz</OPTION>
 <OPTION value="5">silber</OPTION>
 <OPTION value="6">weiss</OPTION></SELECT>

 */

@implementation GSWPopUpButton (GSWPopUpButtonA)

//#define ENABLE_OPTGROUP
//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  id selectionValue=nil;
  id selectedValueValue=nil;
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
  int countValue=0;
  LOGObjectFnStartC("GSWPopUpButton");
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);

  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  component=[context component];

  [super appendToResponse:response
         inContext:context];

  NSDebugMLLog(@"gswdync",@"_list=%@",_list);
  if (_list)
    {
      listValue=[_list valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"listValue=%@",listValue);
      NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                _list,
                listValue,
                [listValue class]);
      countValue=[listValue count];
    };

  NSDebugMLLog(@"gswdync",@"_count=%@",_count);
  if (_count)
    {
      id tmpCountValue=[_count valueInComponent:component];
      int tmpCount=0;
      NSAssert3(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                @"The 'count' (%@) value %@ (of class:%@) doesn't  respond to 'intValue'",
                _count,
                tmpCountValue,
                [tmpCountValue class]);
      tmpCount=[tmpCountValue intValue];
      NSDebugMLog(@"tmpCount=%d",tmpCount);
      if (_list)
        countValue=min(tmpCount,countValue);
      else
        countValue=tmpCount;
    }
  selectionValue=[_selection valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"selection=%@",_selection);
  NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
  selectedValueValue=[_selectedValue valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"selectedValue=%@",_selectedValue);
  NSDebugMLLog(@"gswdync",@"selectedValueValue=%@",selectedValueValue);

  if (_escapeHTML)
    {
      escapeHTMLValue=[_escapeHTML valueInComponent:component];
      escapeHTMLBoolValue=boolValueFor(escapeHTMLValue);
    };

  if (_noSelectionString)
    {
      id noSelectionStringValue=nil;
      [response _appendContentAsciiString:@"\n<OPTION"];
      if (_selectedValue && !selectedValueValue)
        {
          [response appendContentCharacter:' '];
          [response _appendContentAsciiString:@"selected"];//TODO
        };
      [response appendContentCharacter:'>'];

      noSelectionStringValue=[_noSelectionString valueInComponent:component];
      if (escapeHTMLBoolValue)
        noSelectionStringValue=[GSWResponse stringByEscapingHTMLString:noSelectionStringValue];
      [response appendContentString:noSelectionStringValue];
      //[response appendContentHTMLString:_noSelectionStringValue];
      // There is no close tag on OPTION
      //[response _appendContentAsciiString:@"</OPTION>"];
    };

  NSDebugMLLog(@"gswdync",@"countValue=%d",countValue);
  for(i=0;i<countValue;i++)
    {
      NSDebugMLLog(@"gswdync",@"inOptGroup=%s",(inOptGroup ? "YES" : "NO"));
      if (listValue)
        itemValue=[listValue objectAtIndex:i];
      else
        itemValue=[NSNumber numberWithShort:i];
      if (_item)
        [_item setValue:itemValue
               inComponent:component];
      if (_index)
        [_index setValue:[NSNumber numberWithShort:i]
                inComponent:component];

      NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
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
              NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);

              NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
              NSDebugMLLog(@"gswdync",@"selectionValue class=%@",[selectionValue class]);
              NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
              NSDebugMLLog(@"gswdync",@"itemValue class=%@",[itemValue class]);
              if (selectionValue)
                {
                  isEqual=SBIsValueEqual(itemValue,selectionValue);

                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
                };

              if (isEqual == NO && _selectedValue)
                {
                  // selected values is selections but on valueValue not itemValue
                  isEqual=SBIsValueEqual(valueValue,selectedValueValue);

                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
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
            }
          else
            {
              displayStringValue = itemValue;
            }

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
              [response appendContentString:displayStringValue];
              //[response appendContentHTMLString:_displayStringValue];
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
  GSWStopElement(context);
  GSWAssertIsElementID(context);
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context
{
  //Does nothing because value is only printed in OPTION tag
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStartC("GSWPopUpButton");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  [self _slowTakeValuesFromRequest:request
		inContext:context];
  GSWAssertIsElementID(context);
  GSWStopElement(context);
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  //OK
  BOOL disabledValue=NO;
  BOOL wasFormSubmitted=NO;
  LOGObjectFnStartC("GSWPopUpButton");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=nil;
          NSArray* listValue=nil;
          id valueValue=nil;
          NSString* valueValueString=nil;
          id itemValue=nil;
          NSString* name=nil;
          NSArray* formValues=nil;
          id formValue=nil;
          BOOL found=NO;
          int i=0;
          int countValue=0;
          id itemValueToSet=nil;	// Object from list found (==> _selection)
          id valueValueToSet=nil;	// Value Found (==> _selectionValue)

          component=[context component];
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValues=[request formValuesForKey:name];
          NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);

          if (formValues && [formValues count]>0)
            {
              formValue=[formValues objectAtIndex:0];
              NSDebugMLLog(@"gswdync",@"formValue=%@",formValue);
              if (_list)
                {
                  listValue=[_list valueInComponent:component];
                  NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                            @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                            _list,
                            listValue,
                            [listValue class]);
                  countValue=[listValue count];
                }
              if (_count)
                {
                  id tmpCountValue=[_count valueInComponent:component];
                  int tmpCount=0;
                  NSAssert3(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                            @"The 'count' (%@) value %@ (of class:%@) doesn't  respond to 'intValue'",
                            _count,
                            tmpCountValue,
                            [tmpCountValue class]);
                  tmpCount=[tmpCountValue intValue];
                  NSDebugMLog(@"tmpCount=%d",tmpCount);
                  if (_list)
                    countValue=min(tmpCount,countValue);
                  else
                    countValue=tmpCount;
                }
              
              for(i=0;!found && i<countValue;i++)
                {
                  if (listValue)
                    itemValue=[listValue objectAtIndex:i];
                  else
                    itemValue=[NSNumber numberWithShort:i];
                  NSDebugMLLog(@"gswdync",@"_itemValue=%@",itemValue);
                  NSDebugMLLog(@"gswdync",@"_item=%@",_item);
                      
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
                      if (found)
                        {
                          itemValueToSet=itemValue;
                          valueValueToSet=valueValue;
                        }
                    };
                };
            };
          if (_selection)
            {
              NS_DURING
                {
                  NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
                  [_selection setValue:itemValueToSet
                              inComponent:component];
                }
              NS_HANDLER
                {
                  LOGException(@"GSWPopUpButton _selection=%@ itemValueToSet=%@ exception=%@",
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
            };                    

          NSDebugMLLog(@"gswdync",@"selectionValue=%@",_selectionValue);
          if (!WOStrictFlag && _selectionValue)
            {
              NS_DURING
                {
                  [_selectionValue setValue:valueValueToSet
                                   inComponent:component];
                }
              NS_HANDLER
                {
                  LOGException(@"GSWPopUpButton _selectionValue=%@ valueValueToSet=%@ exception=%@",
                               _selectionValue,valueValue,localException);
                  [self handleValidationException:localException
                        inContext:context];
                }
              NS_ENDHANDLER;
            };
        };
    };
  GSWStopElement(context);
  GSWAssertIsElementID(context);
  LOGObjectFnStopC("GSWPopUpButton");
};


@end

//====================================================================
@implementation GSWPopUpButton (GSWPopUpButtonB)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};
@end

