/* GSWAssociation.m - GSWeb: Class GSWAssociation
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

#include <GSWeb/GSWeb.h>
#include <math.h>

static NSDictionary* localMinMaxDictionary=nil;
static NSMutableDictionary* associationsHandlerClasses=nil;
static NSLock* associationsLock=nil;
static NSMutableArray* associationsLogsHandlerClasses=nil;
//====================================================================
@implementation GSWAssociation

+(void)initialize
{
  if (self==[GSWAssociation class])
	{
	  associationsLock=[NSLock new];
	  if (!localMinMaxDictionary)
		{
		  localMinMaxDictionary=[[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSNumber numberWithShort:SCHAR_MIN],@"SCHAR_MIN",
											   [NSNumber numberWithShort:SCHAR_MAX],@"SCHAR_MAX",
											   [NSNumber numberWithShort:UCHAR_MAX],@"UCHAR_MAX",
											   [NSNumber numberWithShort:CHAR_MIN],@"CHAR_MIN",
											   [NSNumber numberWithShort:CHAR_MAX],@"CHAR_MAX",
											   [NSNumber numberWithShort:SHRT_MIN],@"SHRT_MIN",
											   [NSNumber numberWithShort:SHRT_MAX],@"SHRT_MAX",
											   [NSNumber numberWithUnsignedInt:0],@"USHRT_MIN",
											   [NSNumber numberWithUnsignedInt:USHRT_MAX],@"USHRT_MAX",
											   [NSNumber numberWithInt:INT_MIN],@"INT_MIN",
											   [NSNumber numberWithInt:INT_MAX],@"INT_MAX",
											   [NSNumber numberWithUnsignedInt:0],@"UINT_MIN",
											   [NSNumber numberWithUnsignedInt:UINT_MAX],@"UINT_MAX",
											   [NSNumber numberWithLong:LONG_MIN],@"LONG_MIN",
											   [NSNumber numberWithLong:LONG_MAX],@"LONG_MAX",
											   [NSNumber numberWithUnsignedLong:0],@"ULONG_MIN",
											   [NSNumber numberWithUnsignedLong:ULONG_MAX],@"ULONG_MAX",
#ifdef LONG_LONG_MAX

											   [NSNumber numberWithLongLong:LONG_LONG_MIN],@"LONG_LONG_MIN",
											   [NSNumber numberWithLongLong:LONG_LONG_MAX],@"LONG_LONG_MAX",
#endif
#ifdef ULONG_LONG_MAX
											   [NSNumber numberWithUnsignedLongLong:0],@"ULONG_LONG_MIN",
											   [NSNumber numberWithUnsignedLongLong:ULONG_LONG_MAX],@"ULONG_LONG_MAX",
#endif
											   [NSNumber numberWithFloat:FLT_MIN],@"FLOAT_MIN",
											   [NSNumber numberWithFloat:FLT_MAX],@"FLOAT_MAX",
											   [NSNumber numberWithFloat:DBL_MIN],@"DOUBLE_MIN",
											   [NSNumber numberWithFloat:DBL_MAX],@"DOUBLE_MAX",
											   nil,nil]
								  retain];
		};
	};
};

//--------------------------------------------------------------------
+(void)dealloc
{
  DESTROY(localMinMaxDictionary);
  DESTROY(associationsHandlerClasses);
  DESTROY(associationsLogsHandlerClasses);
  DESTROY(associationsLock);
};

//--------------------------------------------------------------------
//	init
-(id)init
{
  if ((self=[super init]))
	{
	};
  return self;
};

-(void)dealloc
{
  DESTROY(bindingName);
  DESTROY(declarationName);
  DESTROY(declarationType);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWAssociation* clone = [[isa allocWithZone:zone] init];
  clone->debugEnabled=debugEnabled;
  [clone setDebugEnabledForBinding:bindingName
		 declarationName:declarationName
		 declarationType:declarationType];
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  GSWLogAssertGood(self);
  LOGObjectFnNotImplemented();	//TODOFN
  return [super description];
};

//--------------------------------------------------------------------
-(NSString*)bindingName
{
  return bindingName;
};

//--------------------------------------------------------------------
-(NSString*)declarationName
{
  return declarationName;
};

//--------------------------------------------------------------------
-(NSString*)declarationType
{
  return declarationType;
};

//--------------------------------------------------------------------
//	isValueConstant

-(BOOL)isValueConstant 
{
  //OK
  [self subclassResponsibility:_cmd];
  return NO;
};

//--------------------------------------------------------------------
//	isValueSettable

- (BOOL)isValueSettable 
{
  //OK
  [self subclassResponsibility:_cmd];
  return NO;
};

//--------------------------------------------------------------------
//	setValue:inObject:
//NDFN
-(void)setValue:(id)value_
	   inObject:(id)object_
{
  //OK
  [self subclassResponsibility:_cmd];
};


//--------------------------------------------------------------------
//	setValue:inComponent:

-(void)setValue:(id)value_ 
	inComponent:(GSWComponent*)component_
{
  //OK
  [self setValue:value_
	   inObject:component_];
};

//--------------------------------------------------------------------
//	valueInObject:
//NDFN
-(id)valueInObject:(id)object_
{
  //OK
  return [self subclassResponsibility:_cmd];
};


//--------------------------------------------------------------------
//	valueInComponent:

-(id)valueInComponent:(GSWComponent*)component_;
{
  //OK
  return [self valueInObject:component_];
};


@end

//====================================================================
@implementation GSWAssociation (GSWAssociationCreation)
//--------------------------------------------------------------------
//	associationWithKeyPath:

+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath_ 
{
  //OK
  if (keyPath_)
	{
	  if ([keyPath_ hasPrefix:@"^"]
              || (!WOStrictFlag && [keyPath_ hasPrefix:@"~"]))
            return [[[GSWBindingNameAssociation alloc]initWithKeyPath:keyPath_] autorelease];
	  else
            return [[[GSWKeyValueAssociation alloc]initWithKeyPath:keyPath_] autorelease];
	}
  else
	return nil;
};


//--------------------------------------------------------------------
//	associationWithValue:

+(GSWAssociation*)associationWithValue:(id)value_ 
{
  //OK
  return [[[GSWConstantValueAssociation alloc]initWithValue:value_] autorelease];
};

//--------------------------------------------------------------------
//	associationFromString:
//NDFN
+(GSWAssociation*)associationFromString:(NSString*)string_
{
  GSWAssociation* _assoc=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"string_=[%@]",string_);
  if ([string_ length]<=0)
	_assoc=[self associationWithValue:string_];
  else
	{
	  NSString* _trimmedString=[string_ stringByTrimmingSpaces];
	  if ([_trimmedString isEqualToString:NSTYES])
		{
		  _assoc=[self associationWithValue:[NSNumber numberWithBool:YES]];
		  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
		}
	  else if ([_trimmedString isEqualToString:NSTNO])
		{
		  _assoc=[self associationWithValue:[NSNumber numberWithBool:NO]];
		  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
		}
	  else if ([_trimmedString hasPrefix:@"^"])
		{
		  _assoc=[self associationWithKeyPath:_trimmedString];
		  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
		}
	  else if ([_trimmedString hasPrefix:@"\""])
		{
		  if ([_trimmedString hasSuffix:@"\""])
			{
			  _assoc=[self associationWithValue:[[_trimmedString stringWithoutPrefix:@"\""] stringWithoutSuffix:@"\""]];
			  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
			}
		  else
			{
			  ExceptionRaise(@"GSWAssociation",@"String '%@' start with a \" but doesn't finish with a \"",
							 _trimmedString);
			};
		}
	  else if ([_trimmedString hasPrefix:@"\'"])
		{
		  if ([_trimmedString hasSuffix:@"\'"])
			{
			  _assoc=[self associationWithValue:[[_trimmedString stringWithoutPrefix:@"\'"] stringWithoutSuffix:@"\'"]];
			  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
			}
		  else
			{
			  ExceptionRaise(@"GSWAssociation",@"String '%@' start with a character ' but doesn't finish with a character '",
							 _trimmedString);
			};
		}
	  else if ([_trimmedString hasPrefix:@"#"])
		{
		  NSString* _numberString=[_trimmedString stringWithoutPrefix:@"#"];
		  //char* cString=[_numberString lossyCString];//TODO
		  char* cString=[_numberString cString];//TODO
		  char* endPtr=NULL;
		  int _value=strtol(cString,&endPtr,16);
		  NSDebugMLLog(@"associations",@"_value=[%d]",_value);
		  if (endPtr && *endPtr)
			{
			  ExceptionRaise(@"GSWAssociation",@"String '%@' start with a '#' but doesn't countain an hexadecimal number (on %dth Character)",
							 _trimmedString,
							 (int)(endPtr-cString+1));
			};
		  _assoc=[self associationWithValue:[NSNumber numberWithInt:_value]];
		}
	  else
		{
		  NSNumber*_limit=[localMinMaxDictionary objectForKey:_trimmedString];
		  NSDebugMLLog(@"associations",@"_limit=[%@]",_limit);
		  if (_limit)
			{
			  _assoc=[self associationWithValue:_limit];
			  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
			}
		  else
			{
			  NSCharacterSet* _cset=[NSCharacterSet characterSetWithCharactersInString:@"-+0123456789"];
			  NSRange _firstCharRange=[_trimmedString rangeOfCharacterFromSet:_cset
													  options:0
													  range:NSMakeRange(0,1)];
			  NSDebugMLLog(@"associations",@"_firstCharRange.length=%d _firstCharRange.location=%d ",_firstCharRange.length,_firstCharRange.location);
			  if (_firstCharRange.length==0 || _firstCharRange.location!=0)
				{
				  _assoc=[self associationWithKeyPath:_trimmedString];
				  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
				}
			  else
				{
				  //char* cString=[_trimmedString lossyCString];//TODO
				  char* cString=[_trimmedString cString];//TODO
				  char* endPtr=NULL;
				  int _value=strtol(cString,&endPtr,10);
				  NSDebugMLLog(@"associations",@"_value=[%d]",_value);
				  if (endPtr && *endPtr)
					{
					  NSDebugMLLog(@"associations",@"endPtr=[%s]",endPtr);
					  NSDebugMLLog(@"associations",@"_value=[%d]",_value);
					  ExceptionRaise(@"GSWAssociation",
									 @"String '%@' must be a good number",
									 _trimmedString);
					};
				  _assoc=[self associationWithValue:[NSNumber numberWithInt:_value]];
				  NSDebugMLLog(@"associations",@"_assoc=[%@]",_assoc);
				};
			};
		};
	};
  LOGClassFnStop();
  return _assoc;
};

//====================================================================
@implementation GSWAssociation (GSWAssociationHandlers)
//--------------------------------------------------------------------
+(void)setClasse:(Class)class_
	  forHandler:(NSString*)handler_
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class_=%@",class_);
  NSDebugMLLog(@"associations",@"handler_=%@",handler_);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
  if (!associationsHandlerClasses)
	{
	  if (class_)
		associationsHandlerClasses=[NSMutableDictionary new];
	};
  if (class_)
	[associationsHandlerClasses setObject:class_
								forKey:handler_];
  else if (associationsHandlerClasses)
	[associationsHandlerClasses removeObjectForKey:handler_];
  TmpUnlock(associationsLock);
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(void)addLogHandlerClasse:(Class)class_
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class_=%@",class_);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
  if (!associationsLogsHandlerClasses)
	{
	  if (class_)
		associationsLogsHandlerClasses=[NSMutableArray new];
	};
  if (class_)
	[associationsLogsHandlerClasses addObject:class_];
  TmpUnlock(associationsLock);
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(void)removeLogHandlerClasse:(Class)class_
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class_=%@",class_);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
  if (associationsHandlerClasses)
	{
	  if (class_)
		[associationsLogsHandlerClasses removeObject:class_];
	};
  TmpUnlock(associationsLock);
  LOGClassFnStop();
};

@end
/*
//====================================================================
@implementation GSWAssociation (GSWAssociationOldFn)
//--------------------------------------------------------------------
//	value

-(id)value
{
  //OK
  GSWContext* context=[[GSWApplication application] context];
  id object=[context component];
  [self valueInComponent:object];
};

//--------------------------------------------------------------------
//	setValue:inComponent:
//OldFn
-(void)setValue:(id)value_
{
  //OK
  GSWContext* context=[[GSWApplication application] context];
  id object=[context component];
  [self setValue:(id)value_ 
		inComponent:object];
};
@end
*/
//====================================================================
@implementation GSWAssociation (GSWAssociationA)

//--------------------------------------------------------------------
-(BOOL)isImplementedForComponent:(NSObject*)component_
{
  //OK
  [self subclassResponsibility:_cmd];
  return NO;
};

@end

//====================================================================
@implementation GSWAssociation (GSWAssociationB)

//--------------------------------------------------------------------
-(NSString*)keyPath
{
  //OK
  [self subclassResponsibility:_cmd];
  return nil;
};

//--------------------------------------------------------------------
-(void)logValue:(id)value_
		 forSet:(BOOL)set_
{
  if (debugEnabled)
	{
	  if (associationsLogsHandlerClasses)
		{
		  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
		  NS_DURING
			{
			  int i=0;
			  Class _class=Nil;
			  int _handlerCount=[associationsLogsHandlerClasses count];
			  NSString* _debugDescription=[self debugDescription];
			  for(i=0;i<_handlerCount;i++)
				{
				  _class=[associationsLogsHandlerClasses objectAtIndex:i];
				  if (set_)
					[_class logSetValueForDeclarationNamed:declarationName
							type:declarationType
							bindingNamed:bindingName
							associationDescription:_debugDescription
							value:value_];
				  else
					[_class logTakeValueForDeclarationNamed:declarationName
							type:declarationType
							bindingNamed:bindingName
							associationDescription:_debugDescription
							value:value_];
				};
			}
		  NS_HANDLER
			{
			  LOGException(@"%@ (%@)",localException,[localException reason]);
			  TmpUnlock(associationsLock);
			  [localException raise];
			}
		  NS_ENDHANDLER;
		  TmpUnlock(associationsLock);
		};
	};
};

//--------------------------------------------------------------------
-(void)logTakeValue:(id)value_
{
  [self logValue:value_
		forSet:NO];
};

//--------------------------------------------------------------------
-(void)logSetValue:(id)value_
{
  [self logValue:value_
		forSet:YES];
};

//--------------------------------------------------------------------
-(void)logSynchronizeForValue:(id)value_
				  inComponent:(NSObject*)component_
			componentToParent:(BOOL)componentToParent_
{
  if (associationsHandlerClasses)
	{
	  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
	  NS_DURING
		{
		  int i=0;
		  Class _class=Nil;
		  int _handlerCount=[associationsLogsHandlerClasses count];
		  NSString* _debugDescription=[self debugDescription];
		  for(i=0;i<_handlerCount;i++)
			{
			  _class=[associationsLogsHandlerClasses objectAtIndex:i];
			  if (componentToParent_)
				[_class	logSynchronizeComponentToParentForValue:value_
						association:self
						inComponent:component_];
			  else
				[_class logSynchronizeParentToComponentForValue:value_
						association:self
						inComponent:component_];
			};
		}
	  NS_HANDLER
		{
		  LOGException(@"%@ (%@)",localException,[localException reason]);
		  TmpUnlock(associationsLock);
		  [localException raise];
		}
	  NS_ENDHANDLER;
	  TmpUnlock(associationsLock);
	};
};

//--------------------------------------------------------------------
-(void)logSynchronizeComponentToParentForValue:(id)value_
								   inComponent:(NSObject*)component_
{
  [self logSynchronizeForValue:value_
		inComponent:component_
		componentToParent:YES];
};
//--------------------------------------------------------------------
-(void)logSynchronizeParentToComponentForValue:(id)value_
								   inComponent:(NSObject*)component_
{
  [self logSynchronizeForValue:value_
		inComponent:component_
		componentToParent:NO];
};

//--------------------------------------------------------------------
-(NSString*)debugDescription
{
  //OK
  [self subclassResponsibility:_cmd];
  return nil;
};

//--------------------------------------------------------------------
-(void)setDebugEnabledForBinding:(NSString*)bindingName_
				 declarationName:(NSString*)declarationName_
				 declarationType:(NSString*)declarationType_
{
  debugEnabled=YES;
  ASSIGN(bindingName,bindingName_);
  ASSIGN(declarationName,declarationName_);
  ASSIGN(declarationType,declarationType_);
};

//--------------------------------------------------------------------
+(id)valueInObject:(id)object_
		forKeyPath:(NSString*)keyPath_
{
  id retValue=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: keyPath_=%@ object_=%p",keyPath_,(void*)object_);
  if (keyPath_ && object_)
	{
	  NSMutableArray* keys=[[keyPath_ componentsSeparatedByString:@"."] mutableCopy];
	  id _part=nil;
	  Class _handlerClass=Nil;
	  retValue=object_;
	  NSAssert(retValue,@"No Component");
	  while(retValue && [keys count]>0)
		{
		  _part=[keys objectAtIndex:0];
		  [keys removeObjectAtIndex:0];
		  NSDebugMLLog(@"associations",@"_part=%@",_part);
		  _handlerClass=[associationsHandlerClasses objectForKey:_part];
		  NSDebugMLLog(@"associations",@"_handlerClass=%@",_handlerClass);
		  if (_handlerClass)
			retValue=[_handlerClass processValueInObject:retValue
									forHandler:_part
									forKeyPath:keys];
		  else if ([_part isEqualToString:GSASK_Class])
			{
			  Class _class=Nil;
			  NSAssert2([keys count]>0,@"No class name for handler %@ in %@",
					   GSASK_Class,
					   keyPath_);
			  _part=[keys objectAtIndex:0];
			  [keys removeObjectAtIndex:0];
			  NSDebugMLLog(@"associations",@"_part=%@",_part);
			  _class=NSClassFromString(_part);
			  NSAssert3(_class>0,@"No class named %@ for handler %@ in %@",
						_part,
						GSASK_Class,
						keyPath_);
			  if (_class)
				retValue=_class;
			  else
				retValue=nil;
			}
		  else
			{
			  NS_DURING
			    retValue=[retValue getIVarNamed:_part];
			  NS_HANDLER
			    NSLog(@"Attempt to get %@/%@ raised an exception (%@)",[retValue class],_part,localException);
        localException = [localException exceptionByAddingToUserInfoKey:@"Invalid Ivars/Methods" format:@"-[%@ %@]",[retValue class],_part];
        [localException raise];
			  NS_ENDHANDLER
			};
		};
	};
  NSDebugMLLog(@"associations",@"retValue=%@",retValue);
  LOGClassFnStop();
  return retValue;
};

//--------------------------------------------------------------------
+(void)setValue:(id)value_
	   inObject:(id)object_
	 forKeyPath:(NSString*)keyPath_
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@",value_);
  NSDebugMLLog(@"associations",@"value_ class:%@",[value_ class]);
  NSDebugMLLog(@"associations",@"value_ String class:%@",NSStringFromClass([value_ class]));
  if (keyPath_)
	{
	  NSMutableArray* keys=[[keyPath_ componentsSeparatedByString:@"."] mutableCopy];
	  id _part=nil;
	  id _object=object_;
	  Class _handlerClass=Nil;
	  NSAssert(_object,@"No Object");
	  while(_object && [keys count]>0)
		{
		  _part=[keys objectAtIndex:0];
		  [keys removeObjectAtIndex:0];
		  NSDebugMLLog(@"associations",@"_part=%@",_part);
		  _handlerClass=[associationsHandlerClasses objectForKey:_part];
		  NSDebugMLLog(@"associations",@"_handlerClass=%@",_handlerClass);
		  if (_handlerClass)
			{
			  _object=[_handlerClass processSetValue:value_
									 inObject:_object
									 forHandler:_part
									 forKeyPath:keys];
			}
		  else
			{
			  if ([keys count]>0)
				{
				  if ([_part isEqualToString:GSASK_Class])
					{
					  Class _class=Nil;
					  NSAssert2([keys count]>0,@"No class name for handler %@ in %@",
								GSASK_Class,
								keyPath_);
					  _part=[keys objectAtIndex:0];
					  [keys removeObjectAtIndex:0];
					  NSDebugMLLog(@"associations",@"_part=%@",_part);
					  _class=NSClassFromString(_part);
					  NSAssert3(_class>0,@"No class named %@ for handler %@ in %@",
								_part,
								GSASK_Class,
								keyPath_);
					  if (_class)
						_object=_class;
					  else
						_object=nil;
					}
				  else
					_object=[_object getIVarNamed:_part];
				}
			  else
				{
				  GSWLogAssertGood(_object);
				  [_object setIVarNamed:_part
						  withValue:value_];
				  _object=nil;
				};
			};
		};	  
	}
  else
	{
	  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@ : NoKeyPath",value_);
	};
  LOGClassFnStop();
};

@end

//===================================================================================
@implementation NSDictionary (GSWAssociation)

-(BOOL)isAssociationDebugEnabledInComponent:(NSObject*)component_
{
  BOOL _debug=NO;
  GSWAssociation* _debugAssociation=[self objectForKey:@"GSWDebug"];
  if (_debugAssociation)
	{
	  id _value=[_debugAssociation valueInObject:component_];
	  _debug=boolValueWithDefaultFor(_value,NO);
	};
  return _debug;
};
  
-(void)associationsSetDebugEnabled
{
  NSEnumerator* enumerator=nil;
  id _key=nil;
  id _asociation=nil;
  LOGObjectFnStart();
  enumerator = [self keyEnumerator];
  while ((_key = [enumerator nextObject]))
	{
	  NSDebugMLLog(@"associations",@"_key=%@",_key);
	  _asociation=[self objectForKey:_key];
	  [_asociation setDebugEnabledForBinding:@""
				   declarationName:_key
				   declarationType:@""];	//TODO
	};
  LOGObjectFnStop();
};

-(void)associationsSetValuesFromObject:(id)from_
							  inObject:(id)to_
{
  NSEnumerator *enumerator = nil;
  id _key=nil;
  id _varValue=nil;
  id _var=nil;
  LOGObjectFnStart();
  enumerator = [self keyEnumerator];
  while ((_key = [enumerator nextObject]))
	{
	  NSDebugMLLog(@"associations",@"_key=%@",_key);
	  _var=[self objectForKey:_key];
	  NSDebugMLLog(@"associations",@"_var=%@",_var);
	  _varValue=[_var valueInComponent:from_];
	  NSDebugMLLog(@"associations",@"_varValue=%@",_varValue);
	  [_key setValue:_varValue
			inComponent:to_];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)associationsWithoutPrefix:(NSString*)prefix_
							   removeFrom:(NSMutableDictionary*)removeFrom_
{
  NSMutableDictionary* _newAssociation=nil;
  NSEnumerator *enumerator = nil;
  id _key=nil;
  id _varKey=nil;
  id _varKeyAssociation=nil;
  id _value=nil;
  LOGObjectFnStart();
  _newAssociation=[NSMutableDictionary dictionary];
  enumerator = [self keyEnumerator];
  while ((_key = [enumerator nextObject]))
	{
	  NSDebugMLLog(@"associations",@"_key=%@",_key);
	  if ([_key hasPrefix:prefix_])
		{
		  [removeFrom_ removeObjectForKey:_key];
		  _value=[self objectForKey:_key];
		  NSDebugMLLog(@"associations",@"_value=%@",_value);
		  _varKey=[_key stringWithoutPrefix:prefix_];
		  NSDebugMLLog(@"associations",@"_varKey=%@",_varKey);
		  _varKeyAssociation=[GSWAssociation associationWithKeyPath:_varKey];
		  NSDebugMLLog(@"associations",@"_varKeyAssociation=%@",_varKeyAssociation);
		  [_newAssociation setObject:_value
						   forKey:_varKeyAssociation];
		};
	};
  _newAssociation=[NSDictionary dictionaryWithDictionary:_newAssociation];
  LOGObjectFnStop();
  return _newAssociation;
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryByReplacingStringsWithAssociations
{
  NSMutableDictionary* _newDictionary=[NSMutableDictionary dictionary];
  NSEnumerator* _enum=[self keyEnumerator];
  id _key=nil;
  id _value=nil;
  id _newValue=nil;
  while ((_key=[_enum nextObject]))
	{
	  _value=[self objectForKey:_key];
	  NSDebugMLog(@"_key=%@ _value=%@",_key,_value);
	  if ([_value isKindOfClass:[NSString class]])
		{
		  _newValue=[GSWAssociation associationFromString:_value];
		  NSAssert(_newValue,@"Nil value");
		}
	  else if ([_value isKindOfClass:[NSArray class]])
		{
		  _newValue=[_value arrayByReplacingStringsWithAssociations];
		  NSAssert(_newValue,@"Nil value");
		}
	  else if ([_value isKindOfClass:[NSDictionary class]])
		{
		  _newValue=[_value dictionaryByReplacingStringsWithAssociations];
		  NSAssert(_newValue,@"Nil value");
		}
	  else
		_newValue=_value;
	  [_newDictionary setObject:_newValue
					  forKey:_key];
	};
  return [NSDictionary dictionaryWithDictionary:_newDictionary];
};

@end

//===================================================================================
@implementation NSArray (GSWAssociation)
-(NSArray*)arrayByReplacingStringsWithAssociations
{
  NSMutableArray* _newArray=[NSMutableArray array];
  int _count=[self count];
  int i=0;
  id _value=nil;
  id _newValue=nil;
  for(i=0;i<_count;i++)
	{
	  _value=[self objectAtIndex:i];
	  NSDebugMLog(@"i=%d _value=%@",i,_value);
	  if ([_value isKindOfClass:[NSString class]])
		{
		  _newValue=[GSWAssociation associationFromString:_value];
		}
	  else if ([_value isKindOfClass:[NSArray class]])
		{
		  _newValue=[_value arrayByReplacingStringsWithAssociations];
		}
	  else if ([_value isKindOfClass:[NSDictionary class]])
		{
		  _newValue=[_value dictionaryByReplacingStringsWithAssociations];
		}
	  else
		_newValue=_value;
	  [_newArray addObject:_newValue];
	};
  return [NSArray arrayWithArray:_newArray];
};
@end
