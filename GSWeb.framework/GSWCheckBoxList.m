/** GSWCheckBoxList.m - <title>GSWeb: Class GSWCheckBoxList</title>

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
  [tmpAssociations removeObjectForKey:disabled__Key];
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
          ExceptionRaise0(@"GSWCheckBox",@"'item' parameter must be settable");
        };

      _value = [[associations objectForKey:value__Key
                              withDefaultObject:[_value autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"value=%@",_value);

      _index = [[associations objectForKey:index__Key
                              withDefaultObject:[_index autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"index=%@",_index);
      if (_index && ![_index isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'index' parameter must be settable");
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
      if (![_selections isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'selection' parameter must be settable");
        };
      
      _displayString = [[associations objectForKey:displayString__Key
                                      withDefaultObject:[_displayString autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"displayString=%@",_displayString);
	  
      _itemDisabled = [[associations objectForKey:disabled__Key
                                     withDefaultObject:[_itemDisabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"itemDisabled=%@",_itemDisabled);

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

  [self resetAutoValue];
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
	{
	  GSWComponent* component=[context component];
	  NSArray* listValue=nil;
	  NSMutableArray* selectionsValues=nil;
	  NSString* name=nil;
	  NSArray* formValues=nil;
	  id valueValue=nil;
	  int i=0;

	  name=[self nameInContext:context];
	  NSDebugMLLog(@"gswdync",@"name=%@",name);
	  formValues=[request formValuesForKey:name];
	  NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);
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

	      if (_item)
		[_item setValue:[listValue objectAtIndex:i]
                       inComponent:component];
	      else if (_index)
		[_index setValue:[NSNumber numberWithShort:i]
                        inComponent:component];
	      NSDebugMLLog(@"gswdync",@"value=%@",_value);

	      valueValue=[self valueInContext:context];
	      NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);

	      if (valueValue)
		{
		  BOOL found=[formValues containsObject:valueValue];

		  NSDebugMLLog(@"gswdync",@"found=%s",(found ? "YES" : "NO"));
		  if (found)
		    {
		      if (!selectionsValues)
			selectionsValues=[NSMutableArray array];

		      if(_autoValue == NO)
			[selectionsValues addObject:valueValue];
		      else
			[selectionsValues addObject:[listValue objectAtIndex:i]];
		    };
		};
	    };
	  NSDebugMLLog(@"gswdync",@"component=%@",component);
	  NSDebugMLLog(@"gswdync",@"selectionsValues=%d",selectionsValues);
	  NSDebugMLLog(@"gswdync",@"selections=%@",_selections);
	  GSWLogAssertGood(component);
          if (!WOStrictFlag)
            {
              NS_DURING
                {
                  [_selections setValue:selectionsValues
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
              [_selections setValue:selectionsValues
                           inComponent:component];
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
  BOOL isEqual=NO;

  LOGObjectFnStartC("GSWCheckBoxList");

  [self resetAutoValue];
  _autoValue = NO;

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
      int i=0;
      id displayStringValue=nil;
      id prefixValue=nil;
      id suffixValue=nil;
      id valueValue=nil;
      BOOL disableValue=NO;
      NSArray* listValue=[_list valueInComponent:component];

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
	  disableValue=[self evaluateCondition:_itemDisabled
                             inContext:context];
	  [_index setValue:[NSNumber numberWithShort:i]
                  inComponent:component];
	  displayStringValue=[_displayString valueInComponent:component];
	  [response appendContentString:@"<INPUT NAME=\""];
	  [response appendContentString:name];
	  [response appendContentString:@"\" TYPE=checkbox VALUE=\""];
	  valueValue = [self valueInContext:context];
	  [response appendContentHTMLAttributeValue:valueValue];
	  [response appendContentCharacter:'"'];

	  //TODOV
	  if(_value)
	    isEqual = [selectionsValue containsObject:valueValue];
	  else
	    {
	      isEqual = [selectionsValue containsObject:[listValue objectAtIndex:i]];

	      _autoValue = YES;
	    }

	  if(isEqual)
	    [response appendContentString:@"\" CHECKED"];

	  if (disableValue) 
	    [response appendContentString:@"\" DISABLED"];

	  [response appendContentCharacter:'>'];
	  [response appendContentString:prefixValue];
	  [response appendContentHTMLString:displayStringValue];
	  [response appendContentString:suffixValue];
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
