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
  int countValue=0;
  LOGObjectFnStartC("GSWPopUpButton");
  [self resetAutoValue];
  _autoValue = NO;
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
          NSDebugMLLog(@"gswdync",@"value=%@",_value);
          if (_value)
            valueValue=[self valueInContext:context];
          else
            {
              _autoValue = YES;
              valueValue = itemValue;
            };
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
          if (valueValue)
            {
              BOOL isEqual=NO;

              NSDebugMLLog0(@"gswdync",@"Adding OPTION");
              [response _appendContentAsciiString:@"\n<OPTION"];
              NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
              if (_selection)
                {
                  if (_value)
                    {
                      isEqual=SBIsValueEqual(valueValue,selectionValue);
                      //We can have a value but want to compare on item/selection object
                      if (!isEqual)
                        isEqual=(itemValue && (itemValue==selectionValue));
                    }
                  else
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
                  if(_value)
                    isEqual=SBIsValueEqual(valueValue,selectedValueValue);
                  else
                    isEqual=SBIsValueEqual(itemValue,selectedValueValue);

                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
                };
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
          int countValue=0;
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
                  NSDebugMLLog(@"gswdync",@"itemValue %p=%@ (class %@)",itemValue,itemValue,[itemValue class]);
                  NSDebugMLLog(@"gswdync",@"item=%@",_item);
                  if (_item)
                    [_item setValue:itemValue
                           inComponent:component];
                  if (_index)
                    [_index setValue:[NSNumber numberWithShort:i]
                            inComponent:component];
                  NSDebugMLLog(@"gswdync",@"value=%@",_value);
                  if (_value)
                    valueValue=[self valueInContext:context];
                  else
                    {
                      _autoValue = YES;
                      valueValue=itemValue;
                    };
                  NSDebugMLLog(@"gswdync",@"valueValue=%@ [class=%@] formValue=%@ [class=%@]",
                               valueValue,[valueValue class],
                               formValue,[formValue class]);
                  isEqual=SBIsValueEqual(valueValue,formValue);
                  if (isEqual)
                    {
                      NSDebugMLLog(@"gswdync",@"selection=%@",_selection);
                      if (_selection)
                        {
                          NS_DURING
                            {
                              NSDebugMLLog(@"gswdync",@"itemValue=%@",itemValue);
                              [_selection setValue:itemValue
                                          inComponent:component];
                            }
                          NS_HANDLER
                            {
                              LOGException(@"GSWPopUpButton _value=%@ resultValue=%@ exception=%@",
                                           _value,resultValue,localException);
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
                      if (!WOStrictFlag)
                        {
                          NSDebugMLLog(@"gswdync",@"selectionValue=%@",_selectionValue);
                          if (_selectionValue)
                            {
                              NS_DURING
                                {
                                  [_selectionValue setValue:valueValue
                                                  inComponent:component];
                                }
                              NS_HANDLER
                                {
                                  LOGException(@"GSWPopUpButton _selectionValue=%@ valueValue=%@ exception=%@",
                                               _selectionValue,valueValue,localException);
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
                  NS_DURING
                    {
                      [_selection setValue:nil
                                  inComponent:component];
                    }
                  NS_HANDLER
                    {
                      LOGException(@"GSWPopUpButton _selection=%@ exception=%@",
                                   _selection,localException);
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
              if (!WOStrictFlag && _selectionValue)
                {
                  NS_DURING
                    {
                      [_selectionValue setValue:nil
                                       inComponent:component];
                    };
                  NS_HANDLER
                    {
                      LOGException(@"GSWPopUpButton _selectionValue=%@ exception=%@",
                                   _selectionValue,localException);
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

