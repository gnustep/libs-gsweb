/* GSWBrowser.m - GSWeb: Class GSWBrowser
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWBrowser

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
     associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  //OK
  NSMutableDictionary* _associations=nil;
  LOGObjectFnStartC("GSWBrowser");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements=%@",name_,associations_,elements_);
  _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  [_associations removeObjectForKey:list__Key];
  [_associations removeObjectForKey:item__Key];
  [_associations removeObjectForKey:displayString__Key];
  [_associations removeObjectForKey:selections__Key];
#if !GSWEB_STRICT
  [_associations removeObjectForKey:selectionValues__Key];
#endif
  [_associations removeObjectForKey:selectedValues__Key];
  [_associations removeObjectForKey:size__Key];
  [_associations removeObjectForKey:multiple__Key];
  [_associations removeObjectForKey:escapeHTML__Key];

  if ((self=[super initWithName:name_
                   associations:_associations
                   contentElements:nil]))
    {
      list=[[associations_ objectForKey:list__Key
                           withDefaultObject:[list autorelease]] retain];
      item=[[associations_ objectForKey:item__Key
                           withDefaultObject:[item autorelease]] retain];
      displayString=[[associations_ objectForKey:displayString__Key
                                    withDefaultObject:[displayString autorelease]] retain];
      selections=[[associations_ objectForKey:selection__Key
                                 withDefaultObject:[selections autorelease]] retain];
      if (selections && ![selections isValueSettable])
        {
          //TODO
        };

#if !GSWEB_STRICT
      selectionValues=[[associations_ objectForKey:selectionValue__Key
                                      withDefaultObject:[selectionValues autorelease]] retain];
      if (selectionValues && ![selectionValues isValueSettable])
        {
          //TODO
        };
#endif
      
      selectedValues=[[associations_ objectForKey:selectedValues__Key
                                     withDefaultObject:[selectedValues autorelease]] retain];
      size=[[associations_ objectForKey:size__Key
                           withDefaultObject:[size autorelease]] retain];
      multiple=[[associations_ objectForKey:multiple__Key
                               withDefaultObject:[multiple autorelease]] retain];
      escapeHTML=[[associations_ objectForKey:escapeHTML__Key
                                 withDefaultObject:[escapeHTML autorelease]] retain];
    };
  LOGObjectFnStopC("GSWBrowser");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(list);
  DESTROY(item);
  DESTROY(displayString);
  DESTROY(selections);
#if !GSWEB_STRICT
  DESTROY(selectionValues);
#endif
  DESTROY(selectedValues);
  DESTROY(size);
  DESTROY(multiple);
  DESTROY(escapeHTML);
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

-(void)appendToResponse:(GSWResponse*)response_
              inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=nil;
  BOOL _isFromClientComponent=NO;
  GSWComponent* _component=nil;
  NSArray* _listValue=nil;
  id _selectionsValue=nil;
  id _selectedValuesValue=nil;
  id _valueValue=nil;
  id _itemValue=nil;
  id _displayStringValue=nil;
  BOOL _escapeHTML=YES;
  id _escapeHTMLValue=nil;
  BOOL _isMultiple=NO;
  int i=0;
  BOOL _inOptGroup=NO;
#ifndef ENABLE_OPTGROUP
  BOOL _optGroupLabel=NO;
#endif
  LOGObjectFnStartC("GSWBrowser");
  [self resetAutoValue];
  autoValue = NO;
  _request=[context_ request];
  _isFromClientComponent=[_request isFromClientComponent];
  _component=[context_ component];
//TODO: multiple
  [super appendToResponse:response_
         inContext:context_];
  _listValue=[list valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"_listValue=%@",_listValue);
  NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
            @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
            list,
            _listValue,
            [_listValue class]);
  _selectionsValue=[selections valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"selections=%@",selections);
  NSDebugMLLog(@"gswdync",@"_selectionsValue=%@",_selectionsValue);
  _selectedValuesValue=[selectedValues valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"selectedValues=%@",selectedValues);
  NSDebugMLLog(@"gswdync",@"_selectedValuesValue=%@",_selectedValuesValue);
  if (escapeHTML)
    {
      _escapeHTMLValue=[escapeHTML valueInComponent:_component];
      _escapeHTML=boolValueFor(_escapeHTMLValue);
    };
  if (multiple)
    {
      id _multipleValue=nil;
      _multipleValue=[multiple valueInComponent:_component];
      _isMultiple=boolValueFor(_multipleValue);
    };
  for(i=0;i<[_listValue count];i++)
    {
      NSDebugMLLog(@"gswdync",@"_inOptGroup=%s",(_inOptGroup ? "YES" : "NO"));
      _itemValue=[_listValue objectAtIndex:i];
      if (item)
        [item setValue:_itemValue
              inComponent:_component];
      NSDebugMLLog(@"gswdync",@"_itemValue=%@",_itemValue);
      if (_itemValue)
        {
          NSDebugMLLog(@"gswdync",@"value=%@",value);
          _valueValue=[self valueInContext:context_];
          NSDebugMLLog(@"gswdync",@"_valueValue=%@",_valueValue);
          if (_valueValue)
            {
              BOOL _isEqual;

              NSDebugMLLog0(@"gswdync",@"Adding OPTION");
              [response_ _appendContentAsciiString:@"\n<OPTION"];
              if (selections)
                {
                  if(value)
                    _isEqual=SBIsValueIsIn(_valueValue,_selectionsValue);
                  else
                    _isEqual=SBIsValueIsIn(_itemValue,_selectionsValue);

                  if (_isEqual)
                    {
                      [response_ appendContentCharacter:' '];
                      [response_ _appendContentAsciiString:@"selected"];
                    };
                };
              if (_isEqual == NO && selectedValues)
                {
                  if(value)
                    _isEqual=SBIsValueIsIn(_valueValue,_selectedValuesValue);
                  else
                    _isEqual=SBIsValueIsIn(_itemValue,_selectedValuesValue);

                  if (_isEqual)
                    {
                      [response_ appendContentCharacter:' '];
                      [response_ _appendContentAsciiString:@"selected"];
                    };
                };
              if (value == nil)
                autoValue = YES;
              if (_valueValue)
                {
                  [response_ _appendContentAsciiString:@" value=\""];
                  [response_ _appendContentAsciiString:_valueValue];
                  [response_ appendContentCharacter:'"'];
                };
              [response_ appendContentCharacter:'>'];
            };
          _displayStringValue=nil;
          if (displayString)
            {
              NSDebugMLLog(@"gswdync",@"displayString=%@",displayString);
              _displayStringValue=[displayString valueInComponent:_component];
              NSDebugMLLog(@"gswdync",@"_displayStringValue=%@",_displayStringValue);
            };

          if (_displayStringValue)
            {
              if (!_valueValue)
                {
                  if (_inOptGroup)
                    {
                      NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
#ifdef ENABLE_OPTGROUP
                      [response_ _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
                      _inOptGroup=NO;
                    };
                  NSDebugMLLog0(@"gswdync",@"Adding OPTGROUP");
#ifdef ENABLE_OPTGROUP
                  [response_ _appendContentAsciiString:@"\n<OPTGROUP label=\""];
#else
#if 0
                  [response_ _appendContentAsciiString:@"\n<OPTION>-- "];
                  _optGroupLabel=YES;
#else
                  [response_ _appendContentAsciiString:@"\n<OPTION>"];
#endif
                  _optGroupLabel=YES;
#endif
                  _inOptGroup=YES;
                };
              //<OPTGROUP label="PortMaster 3">
              
              if (_escapeHTML)
                _displayStringValue=[GSWResponse stringByEscapingHTMLString:_displayStringValue];
              NSDebugMLLog(@"gswdync",@"_displayStringValue=%@",_displayStringValue);
#ifndef ENABLE_OPTGROUP
              if (_optGroupLabel)
                {
                  _displayStringValue=[NSString stringWithFormat:@"%@ --",_displayStringValue];
                };
#endif
              [response_ appendContentHTMLString:_displayStringValue];
            };
          if (_valueValue)
            {
              //NSDebugMLLog0(@"gswdync",@"Adding /OPTION");
              // K2- No /OPTION TAG
              //[response_ _appendContentAsciiString:@"</OPTION>"];
            }
          else
            {
              NSDebugMLLog0(@"gswdync",@"Adding > or </OPTION>");
#ifdef ENABLE_OPTGROUP
              [response_ _appendContentAsciiString:@"\">"];
#else
              if (_optGroupLabel)
                {
                  //[response_ _appendContentAsciiString:@"</OPTION>"];
                  _optGroupLabel=NO;
                };
#endif
            };
        };
    };
  if (_inOptGroup)
    {
#ifdef ENABLE_OPTGROUP
      NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
      [response_ _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
      _inOptGroup=NO;
    };
  [response_ _appendContentAsciiString:@"</SELECT>"];
  LOGObjectFnStopC("GSWBrowser");
};

//-------------------------------------------------------------------- 

-(void)takeValuesFromRequest:(GSWRequest*)request_
                   inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStartC("GSWPopUpButton");
  [self _slowTakeValuesFromRequest:request_
		inContext:context_];
  LOGObjectFnStopC("GSWPopUpButton");
};

//-------------------------------------------------------------------- 
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request_
                        inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabled=NO;
  BOOL _wasFormSubmitted=NO;
  LOGObjectFnStartC("GSWPopUpButton");
  [self resetAutoValue];
  _disabled=[self disabledInContext:context_];
  if (!_disabled)
    {
      _wasFormSubmitted=[context_ _wasFormSubmitted];
      if (_wasFormSubmitted)
        {
          BOOL _isMultiple=NO;
          NSArray* _foundValues=nil;
          NSMutableArray* _mutableFoundValues=[NSMutableArray array];
          GSWComponent* _component=nil;
          NSArray* _listValue=nil;
          id _valueValue=nil;
          id _itemValue=nil;
          NSString* _name=nil;
          NSArray* _formValues=nil;
          id _formValue=nil;
          BOOL _found=NO;
          int i=0;
          _component=[context_ component];
          _name=[self nameInContext:context_];
          NSDebugMLLog(@"gswdync",@"_name=%@",_name);
          if (multiple)
            {
              id _multipleValue=[multiple valueInComponent:_component];
              _isMultiple=boolValueFor(_multipleValue);
            };
          _formValues=[request_ formValuesForKey:_name];
          NSDebugMLLog(@"gswdync",@"_formValues=%@",_formValues);
          if (_formValues && [_formValues count])
            {
              BOOL _isEqual=NO;
              _formValue=[_formValues objectAtIndex:0];
              NSDebugMLLog(@"gswdync",@"_formValue=%@",_formValue);
              _listValue=[list valueInComponent:_component];
              NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
                        @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
                        list,
                        _listValue,
                        [_listValue class]);
              for(i=0;(!_found || _isMultiple) && i<[_listValue count];i++)
                {
                  _itemValue=[_listValue objectAtIndex:i];
                  NSDebugMLLog(@"gswdync",@"_itemValue=%@",_itemValue);
                  NSDebugMLLog(@"gswdync",@"item=%@",item);
                  if (item)
                    [item setValue:_itemValue
                          inComponent:_component];
                  NSDebugMLLog(@"gswdync",@"value=%@",value);
                  _valueValue=[self valueInContext:context_];
                  NSDebugMLLog(@"gswdync",@"_valueValue=%@ [class=%@] _formValue=%@ [class=%@]",
                               _valueValue,[_valueValue class],
                               _formValue,[_formValue class]);
                  _isEqual=SBIsValueIsIn(_valueValue,_formValue);
                  if (_isEqual)
                    {
                      if(autoValue == NO)
                        _itemValue = _valueValue;
                      [_mutableFoundValues addObject:_itemValue];
                      _found=YES;
                    };
                };
            };
          _foundValues=[NSArray arrayWithArray:_mutableFoundValues];
          NSDebugMLLog(@"gswdync",@"_found=%s",(_found ? "YES" : "NO"));
          if (selections)
            {
#if !GSWEB_STRICT
              NS_DURING
                {
                  [selections setValue:_foundValues
                              inComponent:_component];
                };
              NS_HANDLER
                {
                  [self handleValidationException:localException
                        inContext:context_];
                }
              NS_ENDHANDLER;
#else
              [selections setValue:_foundValues
                          inComponent:_component];
#endif
                };
#if !GSWEB_STRICT
          if (selectionValues)
            {
              NS_DURING
                {
                  [selectionValues setValue:_foundValues
                                   inComponent:_component];
                };
              NS_HANDLER
                {
                  [self handleValidationException:localException
                        inContext:context_];
                }
              NS_ENDHANDLER;
            };
#endif
        };
    };
  LOGObjectFnStopC("GSWPopUpButton");
};

//-------------------------------------------------------------------- 
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request_
                        inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//-------------------------------------------------------------------- 
@end

//====================================================================
@implementation GSWBrowser (GSWBrowserB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
                                      inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(void)appendValueToResponse:(GSWResponse*)response_
                   inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
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
