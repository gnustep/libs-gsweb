/** GSWPopUpButton.m - <title>GSWeb: Class GSWPopUpButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

static SEL objectAtIndexSEL = NULL;
static SEL setValueInComponentSEL = NULL;
static SEL valueInComponentSEL = NULL;

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWPopUpButton class])
    {
      objectAtIndexSEL=@selector(objectAtIndex:);
      setValueInComponentSEL=@selector(setValue:inComponent:);
      valueInComponentSEL=@selector(valueInComponent:);
    };
};

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
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
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
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  request=[aContext request];
  isFromClientComponent=[request isFromClientComponent];
  component=GSWContext_component(aContext);

  [super appendToResponse:aResponse
         inContext:aContext];

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
      noSelectionStringValue=[_noSelectionString valueInComponent:component];
      if (noSelectionStringValue)
        {
          GSWResponse_appendContentAsciiString(aResponse,@"\n<OPTION");
          if (_selectedValue && !selectedValueValue)
            GSWResponse_appendContentAsciiString(aResponse,@" selected>");//TODO
          else
            GSWResponse_appendContentCharacter(aResponse,'>');
          
          if (escapeHTMLBoolValue)
            noSelectionStringValue=GSWResponse_stringByEscapingHTMLString(aResponse,noSelectionStringValue);
          GSWResponse_appendContentString(aResponse,noSelectionStringValue);
          //GSWResponse_appendContentHTMLString(aResponse,_noSelectionStringValue];
          // There is no close tag on OPTION
          //GSWResponse_appendContentAsciiString(aResponse,@"</OPTION>"];
        };
    };

  NSDebugMLLog(@"gswdync",@"countValue=%d",countValue);

  if (countValue>0)
    {
      IMP listOAIIMP=[listValue methodForSelector:objectAtIndexSEL];
      IMP itemSetValueIMP=[_item methodForSelector:setValueInComponentSEL];
      IMP indexSetValueIMP=[_index methodForSelector:setValueInComponentSEL];
      IMP valueValueIMP=[_value methodForSelector:valueInComponentSEL];
      IMP displayStringValueIMP=[_displayString methodForSelector:valueInComponentSEL];

      for(i=0;i<countValue;i++)
        {
          NSDebugMLLog(@"gswdync",@"inOptGroup=%s",(inOptGroup ? "YES" : "NO"));
          if (listValue)
            itemValue=(*listOAIIMP)(listValue,objectAtIndexSEL,i);
          else
            itemValue=GSWIntNumber(i);

          if (_item)
            (*itemSetValueIMP)(_item,setValueInComponentSEL,
                               itemValue,component);

          if (_index)
            (*indexSetValueIMP)(_index,setValueInComponentSEL,
                                GSWIntNumber(i),component);
          
          NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
          if (itemValue)
            {
              NSDebugMLLog(@"gswdync",@"_value (class: %@): %@",[_value class],_value);
              // Value property of the INPUT tag
              if (_value)  	// Binded Value          
                valueValue = (*valueValueIMP)(_value,valueInComponentSEL,component);
              else		// Auto Value
                valueValue = GSWIntToNSString(i);
              NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
              
              if (valueValue)
                {
                  BOOL isEqual=NO;
                  
                  NSDebugMLLog0(@"gswdync",@"Adding OPTION");
                  GSWResponse_appendContentAsciiString(aResponse,@"\n<OPTION");
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
                          GSWResponse_appendContentAsciiString(aResponse,@" selected");
                        };
                    };
                  
                  if (isEqual == NO && _selectedValue)
                    {
                      NSDebugMLLog(@"gswdync",@"selectedValueValue [%@]=%@",
                                   [selectedValueValue class],selectedValueValue);
                      NSDebugMLLog(@"gswdync",@"valueValue [%@]=%@",
                                   [valueValue class],valueValue);
                      
                      // selected values is selections but on valueValue not itemValue
                      isEqual=SBIsValueEqual(valueValue,selectedValueValue);
                      
                      NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                      if (isEqual)
                        {
                          GSWResponse_appendContentCharacter(aResponse,' ');
                          GSWResponse_appendContentAsciiString(aResponse,@"selected");
                        };
                    };
                  
                  GSWResponse_appendContentAsciiString(aResponse,@" value=\"");
                  GSWResponse_appendContentHTMLAttributeValue(aResponse,valueValue);
                  GSWResponse_appendContentCharacter(aResponse,'"');
                  GSWResponse_appendContentCharacter(aResponse,'>');
                };
              displayStringValue=nil;
              if (_displayString)
                {
                  NSDebugMLLog(@"gswdync",@"displayString=%@",_displayString);
                  displayStringValue=(*displayStringValueIMP)(_displayString,
                                                              valueInComponentSEL,component);
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
                          GSWResponse_appendContentAsciiString(aResponse,@"\n</OPTGROUP>");
#endif
                          inOptGroup=NO;
                        };
                      NSDebugMLLog0(@"gswdync",@"Adding OPTGROUP");
#ifdef ENABLE_OPTGROUP
                      GSWResponse_appendContentAsciiString(aResponse,@"\n<OPTGROUP label=\"");
#else
#if 0
                      GSWResponse_appendContentAsciiString(aResponse,@"\n<OPTION>-- ");
                      optGroupLabel=YES;
#else
                      GSWResponse_appendContentAsciiString(aResponse,@"\n<OPTION>");
#endif
                      optGroupLabel=YES;
#endif
                      inOptGroup=YES;
                    };
                  //<OPTGROUP label="PortMaster 3">
                  
                  if (escapeHTMLBoolValue)
                    displayStringValue=GSWResponse_stringByEscapingHTMLString(aResponse,displayStringValue);

                  NSDebugMLLog(@"gswdync",@"displayStringValue=%@",displayStringValue);
#ifndef ENABLE_OPTGROUP
                  if (optGroupLabel)
                    {
                      displayStringValue=[NSString stringWithFormat:@"%@ --",displayStringValue];
                    };
#endif
                  GSWResponse_appendContentString(aResponse,displayStringValue);
                  //GSWResponse_appendContentHTMLString(aResponse,_displayStringValue);
                };
              if (valueValue)
                {
                  // K2- No /OPTION TAG
                  //GSWResponse_appendContentAsciiString(aResponse,@"</OPTION>");
                }
              else
                {
                  NSDebugMLLog0(@"gswdync",@"Adding > or </OPTION>");
#ifdef ENABLE_OPTGROUP
                  GSWResponse_appendContentAsciiString(aResponse,@"\">"];
#else
                  if (optGroupLabel)
                    {
                      //GSWResponse_appendContentAsciiString(aResponse,@"</OPTION>");
                      optGroupLabel=NO;
                    };
#endif
                };
            };
        };
    };
  if (inOptGroup)
    {
#ifdef ENABLE_OPTGROUP
      NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
      GSWResponse_appendContentAsciiString(aResponse,@"\n</OPTGROUP>");
#endif
      inOptGroup=NO;
    };
  GSWResponse_appendContentAsciiString(aResponse,@"</SELECT>");
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)aContext
{
  //Does nothing because value is only printed in OPTION tag
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStartC("GSWPopUpButton");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  [self _slowTakeValuesFromRequest:request
		inContext:aContext];
  GSWAssertIsElementID(aContext);
  GSWStopElement(aContext);
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)aContext
{
  //OK
  BOOL disabledValue=NO;
  BOOL wasFormSubmitted=NO;
  LOGObjectFnStartC("GSWPopUpButton");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  disabledValue=[self disabledInContext:aContext];
  if (!disabledValue)
    {
      wasFormSubmitted=[aContext _wasFormSubmitted];
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

          component=GSWContext_component(aContext);
          name=[self nameInContext:aContext];
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
              
              if (countValue>0)
                {
                  IMP listOAIIMP=[listValue methodForSelector:objectAtIndexSEL];
                  IMP itemSetValueIMP=[_item methodForSelector:setValueInComponentSEL];
                  IMP indexSetValueIMP=[_index methodForSelector:setValueInComponentSEL];
                  IMP valueValueIMP=[_value methodForSelector:valueInComponentSEL];
                  
                  for(i=0;!found && i<countValue;i++)
                    {
                      if (listValue)
                        itemValue=(*listOAIIMP)(listValue,objectAtIndexSEL,i);
                      else
                        itemValue=GSWIntNumber(i);
                      NSDebugMLLog(@"gswdync",@"_itemValue=%@",itemValue);
                      NSDebugMLLog(@"gswdync",@"_item=%@",_item);
                      
                      if (_item)
                        (*itemSetValueIMP)(_item,setValueInComponentSEL,itemValue,component);

                      if (_index)
                        (*indexSetValueIMP)(_index,setValueInComponentSEL,GSWIntNumber(i),component);
                      
                      NSDebugMLLog(@"gswdync",@"value=%@",_value);
                      if (_value)  	// Binded Value          
                        {
                          valueValue = (*valueValueIMP)(_value,valueInComponentSEL,component);
                          valueValueString=NSStringWithObject(valueValue);
                        }
                      else		// Auto Value
                        {
                          valueValue=GSWIntNumber(i);
                          valueValueString=GSWIntToNSString(i);
                        };
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
                            inContext:aContext];
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
                        inContext:aContext];
                }
              NS_ENDHANDLER;
            };
        };
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
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

