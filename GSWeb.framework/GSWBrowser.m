/** GSWBrowser.m - <title>GSWeb: Class GSWBrowser</title>

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
      _displayString=[[associations objectForKey:displayString__Key
                                    withDefaultObject:[_displayString autorelease]] retain];
      _selections=[[associations objectForKey:selections__Key
                                 withDefaultObject:[_selections autorelease]] retain];
      if (_selections && ![_selections isValueSettable])
        {
          //TODO
        };

      if (!WOStrictFlag)
        {
          _selectionValues=[[associations objectForKey:selectionValue__Key
                                          withDefaultObject:[_selectionValues autorelease]] retain];
          if (_selectionValues && ![_selectionValues isValueSettable])
            {
              //TODO
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

// PRIVATE!
-(void) _setValues:(NSArray*)mutableFoundValues inArray:(NSMutableArray*)selectionsValue
{
  NSEnumerator *myEnumer;
  id			currentObj;

  myEnumer = [[[selectionsValue copy] autorelease] objectEnumerator];
  while (currentObj = [myEnumer nextObject]) {
    if ([mutableFoundValues containsObject:currentObj]==NO) {
      [selectionsValue removeObject:currentObj];
    }
  }

  myEnumer = [mutableFoundValues objectEnumerator];
  while (currentObj = [myEnumer nextObject]) {
    if ([selectionsValue containsObject:currentObj]==NO) {
      [selectionsValue addObject:currentObj];
    }
  }

}

/*

 On WO it looks like that:

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
  NSString * browserName=nil;
  BOOL escapeHTMLBoolValue=YES;
  id escapeHTMLValue=nil;
  BOOL isMultiple=NO;
  int i=0;
  BOOL inOptGroup=NO;
#ifndef ENABLE_OPTGROUP
  BOOL optGroupLabel=NO;
#endif
  LOGObjectFnStartC("GSWBrowser");
  [self resetAutoValue];
  _autoValue = NO;
  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  component=[context component];
  browserName=[self nameInContext:context];

//TODO: multiple
//  [super appendToResponse:response
//         inContext:context];

  [response _appendContentAsciiString:@"<SELECT"];

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

  [response _appendContentAsciiString:[NSString stringWithFormat:@" NAME=\"%@\"",browserName]];

 
  if (_size)
  {
    [response _appendContentAsciiString:@" SIZE="];
    [response _appendContentAsciiString:[_size valueInComponent:component]];
  } else {
    // do we get an PopUp if we leave that out?
    [response _appendContentAsciiString:@" SIZE=1"];
  }
  if (_multiple)
  {
    id multipleValue=nil;
    multipleValue=[_multiple valueInComponent:component];
    isMultiple=boolValueFor(multipleValue);

    if (isMultiple) {
      [response _appendContentAsciiString:@" MULTIPLE"];
    }
  };
  [response _appendContentAsciiString:@">"];

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
              if (_selections)
                {
                  if(_value)
                    isEqual=SBIsValueIsIn(valueValue,selectionsValue);
                  else
                    isEqual=SBIsValueIsIn(itemValue,selectionsValue);

                  if (isEqual)
                    {
                      [response appendContentCharacter:' '];
                      [response _appendContentAsciiString:@"selected"];
                    };
                };
              if (isEqual == NO && _selectedValues)
                {
                  if(_value)
                    isEqual=SBIsValueIsIn(valueValue,selectedValuesValue);
                  else
                    isEqual=SBIsValueIsIn(itemValue,selectedValuesValue);

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
                // [response _appendContentAsciiString:valueValue];
                [response _appendContentAsciiString:[NSString stringWithFormat:@"%d",i]];
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
  BOOL wasFormSubmitted=NO;
  id selectionsValue=nil;
  BOOL selectionsAreMutable=NO;

  LOGObjectFnStartC("GSWPopUpButton");
  [self resetAutoValue];
  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          BOOL isMultiple=NO;
          NSArray* foundValues=nil;
          NSMutableArray* mutableFoundValues=[NSMutableArray array];
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
              BOOL isEqual=NO;

              formValue=[formValues objectAtIndex:0];
              NSDebugMLLog(@"gswdync",@"formValue=%@",formValue);

              listValue=[_list valueInComponent:component];
              selectionsValue=[_selections valueInComponent:component];


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
                  NSDebugMLLog(@"gswdync",@"value=%@",_value);
                  /*
                  valueValue=[self valueInContext:context];
                  NSLog(@"valueValue is %@",valueValue);

                  NSDebugMLLog(@"gswdync",@"_valueValue=%@ [class=%@] _formValue=%@ [class=%@]",
                               valueValue,[valueValue class],
                               formValue,[formValue class]);
                  isEqual=SBIsValueIsIn(valueValue,formValue);
                  
                  if (isEqual)
                   */
                  if ([formValues containsObject:[NSString stringWithFormat:@"%d",i]])
                    {
                      [mutableFoundValues addObject:itemValue];
                      found=YES;
                    };
                };
            };
          foundValues=[NSArray arrayWithArray:mutableFoundValues];
         // NSLog(@"new foundValues = %@",foundValues);

          NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
          if (_selections)
            {
              if (!WOStrictFlag)
                {
                  NS_DURING
                    {
                    ////  selectionsValue=[_selections valueInComponent:component];
//                      NSLog(@"new _setValues...  = %@  (%@)",selectionsValue,[selectionsValue class]);

//                      [self _setValues:mutableFoundValues
//                               inArray:selectionsValue];
//                      NSLog(@"new _setValues done");

                      [_selections setValue:foundValues
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
                {
                  [_selections setValue:foundValues
                              inComponent:component];
                };
                };
          if (!WOStrictFlag)
            {
              if (_selectionValues)
                {
                  NS_DURING
                    {
                      [_selectionValues setValue:foundValues
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
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context
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
