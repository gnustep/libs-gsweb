/** GSWPopUpButton.m - <title>GSWeb: Class GSWPopUpButton</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

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
          //TODO
        };
      
      if (!WOStrictFlag)
        {
          _selectionValue=[[associations objectForKey:selectionValue__Key
                                         withDefaultObject:[_selectionValue autorelease]] retain];
          if (_selectionValue && ![_selectionValue isValueSettable])
            {
              //TODO
            };
        };
      
      _selectedValue=[[associations objectForKey:selectedValue__Key
                                    withDefaultObject:[_selectedValue autorelease]] retain];
      _noSelectionString=[[associations objectForKey:noSelectionString__Key
                                        withDefaultObject:[_noSelectionString autorelease]] retain];
      _escapeHTML=[[associations objectForKey:escapeHTML__Key
                                 withDefaultObject:[_escapeHTML autorelease]] retain];
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

//====================================================================
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
  LOGObjectFnStartC("GSWPopUpButton");
  [self resetAutoValue];
  _autoValue = NO;
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
  for(i=0;i<[listValue count];i++)
    {
      NSDebugMLLog(@"gswdync",@"inOptGroup=%s",(inOptGroup ? "YES" : "NO"));
      itemValue=[listValue objectAtIndex:i];
      if (_item)
        [_item setValue:itemValue
               inComponent:component];
      NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
      if (itemValue)
        {
          NSDebugMLLog(@"gswdync",@"value=%@",_value);
          valueValue=[self valueInContext:context];
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
          if (valueValue)
            {
              BOOL isEqual;

              NSDebugMLLog0(@"gswdync",@"Adding OPTION");
              [response _appendContentAsciiString:@"\n<OPTION"];
              if (_selection)
                {
                  if (_value)
                    isEqual=SBIsValueEqual(valueValue,selectionValue);
                  else
                    isEqual=SBIsValueEqual(itemValue,selectionValue);

                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
                };
              if (isEqual == NO && _selectedValue)
                {
                  if(_value)
                    isEqual=SBIsValueEqual(valueValue,selectedValueValue);
                  else
                    isEqual=SBIsValueEqual(itemValue,selectedValueValue);

                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
                };
              if (_value == nil)
                _autoValue = YES;
              if (valueValue)
                {
                  [response _appendContentAsciiString:@" value=\""];
                  [response _appendContentAsciiString:valueValue];
                  [response appendContentCharacter:'"'];
                };
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
              //NSDebugMLLog0(@"gswdync",@"Adding /OPTION");
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
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context
{
  //OK
  //Does nothing !
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
  [self resetAutoValue];
  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=nil;
          NSArray* listValue=nil;
          id valueValue=nil;
          id itemValue=nil;
          NSString* name=nil;
          NSArray* formValues=nil;
          id formValue=nil;
          BOOL found=NO;
          int i=0;
          component=[context component];
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValues=[request formValuesForKey:name];
          NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);
          if (formValues && [formValues count])
            {
              BOOL isEqual=NO;
              formValue=[formValues objectAtIndex:0];
              NSDebugMLLog(@"gswdync",@"formValue=%@",formValue);
              listValue=[_list valueInComponent:component];
              NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
                        @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                        _list,
                        listValue,
                        [listValue class]);
              for(i=0;!found && i<[listValue count];i++)
                {
                  itemValue=[listValue objectAtIndex:i];
                  NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
                  NSDebugMLLog(@"gswdync",@"item=%@",_item);
                  if (_item)
                    [_item setValue:itemValue
                           inComponent:component];
                  NSDebugMLLog(@"gswdync",@"value=%@",_value);
                  valueValue=[self valueInContext:context];
                  NSDebugMLLog(@"gswdync",@"valueValue=%@ [class=%@] formValue=%@ [class=%@]",
                               valueValue,[valueValue class],
                               formValue,[formValue class]);
                  isEqual=SBIsValueEqual(valueValue,formValue);
                  if (isEqual)
                    {
                      if(_autoValue == NO)
                        itemValue = valueValue;

                      NSDebugMLLog(@"gswdync",@"selection=%@",_selection);
                      if (_selection)
                        {
                          if (!WOStrictFlag)
                            {
                              NS_DURING
                                {
                                  [_selection setValue:itemValue
                                              inComponent:component];
                                };
                              NS_HANDLER
                                {
                                  [self handleValidationException:localException
                                        inContext:context];
                                }
                              NS_ENDHANDLER;
                            }
                          else
                            [_selection setValue:itemValue
                                        inComponent:component];
                        };
                      if (!WOStrictFlag)
                        {
                          NSDebugMLLog(@"gswdync",@"selectionValue=%@",_selectionValue);
                          if (_selectionValue)
                            {
                              NS_DURING
                                {
                                  [_selectionValue setValue:valueValue
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
                      found=YES;
                    };
                };
            };
          NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
          if (!found)
            {
              if (_selection)
                {
                  if (!WOStrictFlag)
                    {
                      NS_DURING
                        {
                          [_selection setValue:nil
                                      inComponent:component];
                        };
                      NS_HANDLER
                        {
                          [self handleValidationException:localException
                                inContext:context];
                        }
                      NS_ENDHANDLER;
                    }
                  else
                    [_selection setValue:nil
                                inComponent:component];
                };
              if (!WOStrictFlag && _selectionValue)
                {
                  NS_DURING
                    {
                      [_selectionValue setValue:nil
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
    };
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

