/** GSWRadioButtonList.m - <title>GSWeb: Class GSWRadioButtonList</title>

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
@implementation GSWRadioButtonList

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",
               aName,associations,elements);
  _defaultEscapeHTML=1;
  [tmpAssociations removeObjectForKey:list__Key];
  [tmpAssociations removeObjectForKey:item__Key];
  [tmpAssociations removeObjectForKey:index__Key];
  [tmpAssociations removeObjectForKey:selection__Key];
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
          ExceptionRaise0(@"GSWCheckBox",@"'item' parameter must be settable");
        };
      _index=[[associations objectForKey:index__Key
                            withDefaultObject:[_index autorelease]] retain];
      if (_index && ![_index isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'index' parameter must be settable");
        };
      
      _selection=[[associations objectForKey:selection__Key
                                withDefaultObject:[_selection autorelease]] retain];
      if (![_selection isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'selection' parameter must be settable");
        };
      _prefix=[[associations objectForKey:prefix__Key
                             withDefaultObject:[_prefix autorelease]] retain];
      _suffix=[[associations objectForKey:suffix__Key
                             withDefaultObject:[_suffix autorelease]] retain];
      _displayString=[[associations objectForKey:displayString__Key
                                    withDefaultObject:[_displayString autorelease]] retain];
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
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);
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
  LOGObjectFnStart();
  [self _slowTakeValuesFromRequest:request
        inContext:context];
  LOGObjectFnStop();
};

//-----------------------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStart();

  [self resetAutoValue];
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
        {
          GSWComponent* component=[context component];
          NSArray* listValue=nil;
          NSString* name=nil;
          int foundIndex=-1;
          id formValue=nil;
          id valueValue=nil;
          id valueToSet=nil;
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
          for(i=0;i<[listValue count] && foundIndex<0;i++)
            {
              NSDebugMLLog(@"gswdync",@"item=%@",_item);
              NSDebugMLLog(@"gswdync",@"index=%@",_index);
              if (_item)
                [_item setValue:[listValue objectAtIndex:i]
                       inComponent:component];
              else if (_index)
                [_index setValue:[NSNumber numberWithShort:i]
                        inComponent:component];
              NSDebugMLLog(@"gswdync",@"value=%@",_value);

              //TODOV
              valueValue=[self valueInContext:context];
              NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
              if (valueValue)
                {
                  BOOL isEqual=SBIsValueEqual(valueValue,formValue);
                  NSDebugMLLog(@"gswdync",@"isEqual=%s",(isEqual ? "YES" : "NO"));
                  if (isEqual)
                    {
                      if(_autoValue == NO)
                        valueToSet=valueValue;
                      else
                        valueToSet=[listValue objectAtIndex:i];
                      foundIndex=i;
                    };
                };
            };
          NSDebugMLLog(@"gswdync",@"component=%@",component);
          NSDebugMLLog(@"gswdync",@"foundIndex=%d",foundIndex);
          NSDebugMLLog(@"gswdync",@"selection=%@",_selection);
          GSWLogAssertGood(component);
          if (!WOStrictFlag)
            {
              NS_DURING
                {
                  if (foundIndex>=0)
                    [_selection setValue:valueToSet
                                inComponent:component];
                  else
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
            {
              if (foundIndex>=0)
                [_selection setValue:valueToSet
                            inComponent:component];
              else
                [_selection setValue:nil
                            inComponent:component];
            };
        };
    };
  LOGObjectFnStop();
};

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
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
  NSArray* listValue=nil;
  id selectionValue=nil;
  int i=0;
  id displayStringValue=nil;
  id prefixValue=nil;
  id suffixValue=nil;
  id valueValue=nil;
  BOOL isEqual=NO;
  LOGObjectFnStart();
  [self resetAutoValue];
  _autoValue = NO;
  request=[context request];
  isFromClientComponent=[request isFromClientComponent];
  name=[self nameInContext:context];
  component=[context component];
  selectionValue=[_selection valueInComponent:component];
  listValue=[_list valueInComponent:component];
  NSAssert3(!listValue || [listValue respondsToSelector:@selector(count)],
            @"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
            _list,
            listValue,
            [listValue class]);
  for(i=0;i<[listValue count];i++)
    {
      [_item setValue:[listValue objectAtIndex:i]
             inComponent:component];
      prefixValue=[_prefix valueInComponent:component];
      suffixValue=[_suffix valueInComponent:component];
      [_index setValue:[NSNumber numberWithShort:i]
              inComponent:component];
      displayStringValue=[_displayString valueInComponent:component];
      [response appendContentString:@"<INPUT NAME=\""];
      [response appendContentString:_name];
      [response appendContentString:@"\" TYPE=radio VALUE=\""];
      valueValue=[self valueInContext:context];
      [response appendContentHTMLAttributeValue:valueValue];
      [response appendContentCharacter:'"'];
      //TODOV
      if(_value)
        isEqual=SBIsValueEqual(valueValue,selectionValue);
      else
        {
          isEqual=SBIsValueEqual([listValue objectAtIndex:i],selectionValue);
          _autoValue = YES;
        }
      if (isEqual)
        [response appendContentString:@"\" CHECKED"];
      [response appendContentCharacter:'>'];
      [response appendContentString:prefixValue];
      [response appendContentHTMLString:displayStringValue];
      [response appendContentString:suffixValue];
	};
  LOGObjectFnStop();
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
