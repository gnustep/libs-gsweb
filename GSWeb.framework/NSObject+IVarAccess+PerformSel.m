/* NSObject+IVarAccess+PerformSel.m
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

#include "GSWeb.h"

NSMutableDictionary* objectIVarAccessCache_Set=nil;
NSMutableDictionary* objectIVarAccessCache_Get=nil;
NSLock* objectClassLock=nil;

//===================================================================================
typedef enum
{
  NSObjectIVarsAccessType_Error				=	-1,
  NSObjectIVarsAccessType_None				=	0,
  NSObjectIVarsAccessType_PerformSelector,
  NSObjectIVarsAccessType_Invocation,
  
  NSObjectIVarsAccessType_Direct,

  NSObjectIVarsAccessType_Dictionary,
  NSObjectIVarsAccessType_DictionaryWithRemoveObject,
  NSObjectIVarsAccessType_DictionaryWithoutRemoveObject,
  NSObjectIVarsAccessType_EO

} NSObjectIVarsAccessType;

//====================================================================
@interface NSObjectIVarsAccess : NSObject
{
  @public
  NSObjectIVarsAccessType	accessType;
  union
  {
	SEL selector;
	NSInvocation* invocation;
	struct objc_ivar* ivar;
  } infos;
};

+(id)ivarAccess;
@end

//====================================================================
@implementation NSObjectIVarsAccess

//--------------------------------------------------------------------
+(id)ivarAccess
{
  return [[self new]autorelease];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  if (accessType==NSObjectIVarsAccessType_Invocation)
	{
	  DESTROY(infos.invocation);
	};
  [super dealloc];
};
@end

//====================================================================
struct objc_ivar* GSGetInstanceVariableStruct(id obj,
                                              NSString* iVarName,
                                              BOOL underscored)
{
  const char* name=NULL;
  Class class;
  struct objc_ivar_list *ivars=NULL;
  struct objc_ivar      *ivar=NULL;
  if (underscored)
    iVarName=[NSString stringWithFormat:@"_%@",iVarName];
  name=[iVarName cString];
  class=[obj class];
  while (class && !ivar)
    {
      ivars = class->ivars;
      class = class->super_class;
      if (ivars)
        {
          int   i;
          for (i=0;!ivar && i<ivars->ivar_count;i++)
            {
              if (strcmp(ivars->ivar_list[i].ivar_name, name)==0)
                  ivar = &ivars->ivar_list[i];
            };
        };
    };
  return ivar;
};

//--------------------------------------------------------------------
const char* GSGetInstanceVariableType(id obj,
                                      NSString *iVarName,
                                      BOOL underscored)
{
  struct objc_ivar      *ivar = GSGetInstanceVariableStruct(obj,iVarName,underscored);
  if (ivar)
	return ivar->ivar_type;
  else
	return NULL;
};

//====================================================================
@implementation NSObject (IVarsAccess)

//--------------------------------------------------------------------
+(BOOL)isIVarAccessCachingDisabled
{
  return NO;
};

//--------------------------------------------------------------------
+(NSString*)getFunctionNameWithTemplate:(NSString*)tpl
							forVariable:(NSString*)varName
				   uppercaseFirstLetter:(BOOL)uppercaseFirstLetter
{
  NSString* fn=nil;
  if (tpl && [tpl length]>0)
	{
	  NSString* fnMain=nil;
	  if (uppercaseFirstLetter)
		{
		  NSString* first=[[varName substringToIndex:1] uppercaseString];
		  NSString* next=[varName substringFromIndex:1];
		  fnMain=[NSString stringWithFormat:@"%@%@",first,next];
		}
	  else
		fnMain=varName;
	  fn=[NSString stringWithFormat:tpl,fnMain];
	}
  else
	fn=[NSString stringWithString:varName];
  return fn;
};

//--------------------------------------------------------------------
-(SEL)getSelectorWithFunctionTemplate:(NSString*)tpl
						  forVariable:(NSString*)varName
				 uppercaseFirstLetter:(BOOL)uppercaseFirstLetter
{
  NSString* fnName=nil;
  SEL selector=NULL;
  fnName=[NSObject getFunctionNameWithTemplate:tpl
				   forVariable:varName
				   uppercaseFirstLetter:uppercaseFirstLetter];
  selector=NSSelectorFromString(fnName);
  if (selector && ![self respondsToSelector:selector])
	  selector=NULL;
  return selector;
};

#if GDL2

//--------------------------------------------------------------------

- (id)getIVarNamed:(NSString *)name_
{
  id value=nil;
  SEL sel = @selector(valueForKey:);//NEW NSSelectorFromString(@"valueForKey:");
//MGNEW  id	(*imp)(id, SEL, id) = (id (*)(id, SEL, id))[NSObject instanceMethodForSelector: sel];
  NSDebugMLLog(@"low",@"getIVarNamed %@ in %@ %p (superClass:%@)",
               name_,
               [self class],
               self,
               [self superclass]);
  //NSLog(@"%@",name_);
  //NSLog(@"sel (valueForKey <NSObject>) : %d", (int)sel);

  NS_DURING
    value = [self valueForKey:name_];//MGNEW
	//MGNEW value = (*imp)(self, sel, name_);
  NS_HANDLER
    {
      NSDebugMLLog(@"low",@"getIVarNamed %@ in %@ %p (superClass:%@). valueForKey: exception",
                   name_,
                   [self class],
                   self,
                   [self superclass]);
      if([self respondsToSelector:@selector(objectForKey:)] == YES) {
		if (name_) {
			value = [self objectForKey:name_];
		} else {
			value=nil;
		}
	  } else {
          LOGException(@"==> %@ (%@) gvfk from string=%p gvfk sel=%p initWithCapacity from string:=%p initWithCapacity sel:=%p NSStringFromSelector(sel)",
                       localException,
                       [localException reason],
                       NSSelectorFromString(@"valueForKey:"),
                       @selector(valueForKey:),
                       NSSelectorFromString(@"initWithCapacity:"),
                       @selector(initWithCapacity:),
                       NSStringFromSelector(sel));
		[localException raise];
		}
    }
  NS_ENDHANDLER;

  return value;
}

//--------------------------------------------------------------------
- (void)setIVarNamed:(NSString *)name_
	   withValue:(id)value_
{
  SEL sel = @selector(takeValue:forKey:);//NEW NSSelectorFromString(@"takeValue:forKey:");
//MGNEW  id	(*imp)(id, SEL, id, id) = (id (*)(id, SEL, id, id))[NSObject instanceMethodForSelector: sel];

  //NSLog(@"sel (takeValue:forKey: <NSObject>) : %d", (int)sel);

  NS_DURING
//NSLog(@"setIVarNamed : self = %@", NSStringFromClass([self class]));
//NSLog(@"setIVarNamed : name_ = %@ (%@)", name_, NSStringFromClass([name_ class]));
//NSLog(@"setIVarNamed : value_ = %@ (%@)", value_, NSStringFromClass([value_ class]));
    [self takeValue:value_ forKey:name_];//MGNEW
	//MGNEW (*imp)(self, sel, value_, name_);
  NS_HANDLER
    {
	if (![name_ isEqualToString:@"self"]) {

      	  if([self respondsToSelector:@selector(setObject:forKey:)] == YES) {
				if (value_ && name_) {
					[self setObject:value_ forKey:name_];
				}
			} else {
				[localException raise];
			}
	}
    }
  NS_ENDHANDLER;
}

#else

//--------------------------------------------------------------------
id PDataToId(const char* retType,void* pdata)
{
  id value=nil;
  switch(*retType)
	{
	case _C_CLASS:
	  value=*((id*)pdata);
	  break;
	case _C_ID:
	  value=*((id*)pdata);
	  break;
	case _C_CHR:
	  value=[NSNumber numberWithChar:*((char*)pdata)];
	  break;
	case _C_UCHR:
	  value=[NSNumber numberWithUnsignedChar:*((unsigned char*)pdata)];
	  break;
	case _C_SHT:
	  value=[NSNumber numberWithShort:*((short*)pdata)];
	  break;
	case _C_USHT:
	  value=[NSNumber numberWithUnsignedShort:*((unsigned short*)pdata)];
	  break;
	case _C_INT:
	  value=[NSNumber numberWithInt:*((int*)pdata)];
	  break;
	case _C_UINT:
	  value=[NSNumber numberWithUnsignedInt:*((unsigned int*)pdata)];
	  break;
	case _C_LNG:
	  value=[NSNumber numberWithLong:*((long*)pdata)];
	  break;
	case _C_ULNG:
	  value=[NSNumber numberWithUnsignedLong:*((unsigned long*)pdata)];
	  break;
	case _C_FLT:
	  value=[NSNumber numberWithFloat:*((float*)pdata)];
	  break;
	case _C_DBL:
	  value=[NSNumber numberWithFloat:*((double*)pdata)];
	  break;
	case _C_CHARPTR:
	  value=[NSString stringWithCString:*((char**)pdata)];
	  break;
	case _C_SEL:
	case _C_VOID:
	case _C_PTR:
	case _C_STRUCT_B:
	default:
	  //TODO
	  break;
	};
  return value;
};

//--------------------------------------------------------------------
void IdToPData(const char* retType,id _value,void* pdata)
{
  switch(*retType)
	{
	case _C_CLASS:
	  *((Class*)pdata)=_value;
	  break;
	case _C_ID:
	  *((id*)pdata)=_value;
	  break;
	case _C_CHR:
	  *((char*)pdata)=[_value charValue];
	  break;
	case _C_UCHR:
	  *((unsigned char*)pdata)=[_value unsignedCharValue];
	  break;
	case _C_SHT:
	  *((short*)pdata)=[_value shortValue];
	  break;
	case _C_USHT:
	  *((unsigned short*)pdata)=[_value unsignedShortValue];
	  break;
	case _C_INT:
	  *((int*)pdata)=[_value intValue];
	  break;
	case _C_UINT:
	  *((unsigned int*)pdata)=[_value unsignedIntValue];
	  break;
	case _C_LNG:
	  *((long*)pdata)=[_value longValue];
	  break;
	case _C_ULNG:
	  *((unsigned long*)pdata)=[_value unsignedLongValue];
	  break;
	case _C_FLT:
	  *((float*)pdata)=[_value floatValue];
	  break;
	case _C_DBL:
	  *((double*)pdata)=[_value doubleValue];
	  break;
	case _C_CHARPTR:
	case _C_SEL:
	case _C_VOID:
	case _C_PTR:
	case _C_STRUCT_B:
	default:
	  //TODO
	  break;
	};
};

//--------------------------------------------------------------------
-(id)getIVarNamed:(NSString*)name_
  withCacheObject:(NSObjectIVarsAccess*)ivarAccess_
{
  id _value=nil;
  switch(ivarAccess_->accessType)
	{
	case NSObjectIVarsAccessType_Error:
	  break;
	case NSObjectIVarsAccessType_None:
	  break;
	case NSObjectIVarsAccessType_PerformSelector:
	  NSDebugMLLog(@"low",@"getIVarNamed %@ in %@ %p (superClass:%@)with performSelector",
				   name_,
				   [self class],
				   self,
				   [self superclass]);
	  _value=[self performSelector:ivarAccess_->infos.selector];
	  break;
	case NSObjectIVarsAccessType_Invocation:
	  {
		const char* retType=[[ivarAccess_->infos.invocation methodSignature] methodReturnType];
		NSAssert([ivarAccess_->infos.invocation selector],@"No Selector in Invocation");
		[ivarAccess_->infos.invocation setTarget:self];
		[ivarAccess_->infos.invocation invoke];
		if (*retType!=_C_VOID)
		  {
			void* pdata=objc_atomic_malloc(objc_sizeof_type(retType));
			if (!pdata)
			  {
                            NSAssert(pdata,@"No ret value buffer");
				//TODO
			  }
			else
			  {
				NSDebugMLLog(@"low",
                                             @"getIVarNamed %@ in %@ %p (superClass:%@) with invocation %@ (retType=%s)",
                                             name_,
                                             [self class],
                                             self,
                                             [self superclass],
                                             ivarAccess_->infos.invocation,
                                             retType);
				[ivarAccess_->infos.invocation getReturnValue:pdata];
				_value=PDataToId(retType,pdata);
				objc_free(pdata);
			  };
		  };
	  };
	  break;
	case NSObjectIVarsAccessType_Direct:
	  {
		const char* IVarType=ivarAccess_->infos.ivar->ivar_type;
		unsigned int size=objc_sizeof_type(IVarType);
		void* pdata=objc_atomic_malloc(size);
		NSDebugMLLog(@"low",@"getIVarNamed %@ in %@ %p (superClass:%@) by variable ",
					 name_,
					 [self class],
					 self,
					 [self superclass]);
		if (pdata)
		  {
			int offset = ivarAccess_->infos.ivar->ivar_offset;
			memcpy(pdata,((void*)self)+offset, size);
			_value=PDataToId(IVarType,pdata);
			objc_free(pdata);
		  }
		else
		  {
			//TODO
                    NSAssert(NO,@"no pdata");
		  };
	  };
	  break;
	case NSObjectIVarsAccessType_Dictionary:
	  _value=[self objectForKey:name_];
	  break;
	case NSObjectIVarsAccessType_EO:
	  _value=[self valueForKey:name_];
	  break;
	default:
	  break;
	};
  return _value;
};

//--------------------------------------------------------------------
-(id)getIVarNamed:(NSString*)name_
{
  id _value=nil;
  NSException* _exception=nil;
  BOOL _cachindEnabled=YES;
  Class _class=Nil;
  NSObjectIVarsAccess* _ivarAccess=nil;
  NSMutableDictionary* _classCache=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"getIVarNamed %@ in %p %@  (superClass:%@)",name_,self,[self class],[self superclass]);
  _class=[self class];
  _classCache=[objectIVarAccessCache_Get objectForKey:_class];
  if (!_classCache)
	{
	  _cachindEnabled=![_class isIVarAccessCachingDisabled];
	  if (_cachindEnabled)
		{
		  if (!objectClassLock)
			objectClassLock=[NSLock new];
		  TmpLockBeforeDate(objectClassLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
		  _classCache=[NSMutableDictionary dictionary];
		  if (!objectIVarAccessCache_Get)
			objectIVarAccessCache_Get=[NSMutableDictionary new];
		  [objectIVarAccessCache_Get setObject:_classCache
									 forKey:_class];
		  TmpUnlock(objectClassLock);
		};
	};
  if (_cachindEnabled)
	_ivarAccess=[_classCache objectForKey:name_];
  if (!_ivarAccess)
	{
	  SEL sel=NULL;
	  _ivarAccess=[NSObjectIVarsAccess ivarAccess];
	  sel=[self getSelectorWithFunctionTemplate:@"get%@"
				forVariable:name_
				uppercaseFirstLetter:YES];
	  if (!sel)
		sel=[self getSelectorWithFunctionTemplate:@"%@"
				  forVariable:name_
				  uppercaseFirstLetter:NO];
	  NSDebugMLLog(@"low",@"getIVarNamed %@ in %@ %p sel=%p ",name_,[self class],self,(void*)sel);
	  if (sel)
		{
		  NSMethodSignature* _sig = [self methodSignatureForSelector:sel];
		  if ([_sig numberOfArguments]!=2)
			{
			  _exception=[NSException exceptionWithName:@"NSObject IVar"
									  format:@"Can't get Variable named %@ in %@ %p (superClass:%@): fn args mismatch",
									  name_,
									  [self class],
									  self,
									  [self superclass]];
			}
		  else
			{
			  const char* retType=[_sig methodReturnType];
                          NSDebugMLLog(@"low",@"retType=%s",retType);
			  if (!retType)
				{
				  _exception=[NSException exceptionWithName:@"NSObject IVar"
								 format:@"Can't get Variable named %@ in %@ %p (superClass:%@): fn unknown type",
								 name_,
								 [self class],
								 self,
								 [self superclass]];
				}
			  else
				{
				  if (*retType==_C_ID)
					{
					  _ivarAccess->accessType=NSObjectIVarsAccessType_PerformSelector;	
					  _ivarAccess->infos.selector=sel;
					}
				  else
					{
					  NSInvocation* _invocation = [NSInvocation invocationWithMethodSignature:_sig];
                                          NSDebugMLLog(@"low",@"_invocation methodSignature methodReturnType=%s",[[_invocation methodSignature] methodReturnType]);
					  [_invocation setSelector:sel];
					  _ivarAccess->accessType=NSObjectIVarsAccessType_Invocation;
					  _ivarAccess->infos.invocation=_invocation;
					  NSAssert([_ivarAccess->infos.invocation selector],@"No Selector in Invocation");
					  [_ivarAccess->infos.invocation retain];
					};
				};
			};
		}
	  else
		{
		  struct objc_ivar* ivar=GSGetInstanceVariableStruct(self,name_,YES);
                  if (!ivar)
                    ivar=GSGetInstanceVariableStruct(self,name_,NO);
		  if (ivar)
			{
			  _ivarAccess->accessType=NSObjectIVarsAccessType_Direct;	
			  _ivarAccess->infos.ivar=ivar;
			}
		  else
			{
			  NSDebugMLLog(@"low",
						   @"getIVarNamed %@ in %@ %p (superClass:%@) with objectForKey ",
						   name_,
						   [self class],
						   self,
						   [self superclass]);
			  if ([self respondsToSelector:@selector(objectForKey:)]) 
				{
				  _ivarAccess->accessType=NSObjectIVarsAccessType_Dictionary;
				}
                          else if ([self respondsToSelector:@selector(valueForKey:)]) 
				{
				  _ivarAccess->accessType=NSObjectIVarsAccessType_EO;
				}
			  else
				{
				  _exception=[NSException exceptionWithName:@"NSObject IVar"
								 format:@"Can't get Variable named %@ in %@ %p (superClass:%@) with objectForKey",
								 name_,
								 [self class],
								 self,
								 [self superclass]];
				};
			};
		};

	  if (_exception)
		_ivarAccess->accessType=NSObjectIVarsAccessType_Error;	
	  if (_cachindEnabled)
		{
		  if (!objectClassLock)
			objectClassLock=[NSLock new];
		  TmpLockBeforeDate(objectClassLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
		  [_classCache setObject:_ivarAccess
					   forKey:name_];
		  TmpUnlock(objectClassLock);
		};
	};
  if (_exception)
	[_exception raise];
  else
	_value=[self getIVarNamed:name_
				 withCacheObject:_ivarAccess];
//  LOGObjectFnStop();
  return _value;
};

//--------------------------------------------------------------------
-(void)setIVarNamed:(NSString*)name_
		  withValue:(id)value_
	withCacheObject:(NSObjectIVarsAccess*)ivarAccess_
{
  LOGObjectFnStart();
  switch(ivarAccess_->accessType)
	{
	case NSObjectIVarsAccessType_Error:
	  break;
	case NSObjectIVarsAccessType_None:
	  break;
	case NSObjectIVarsAccessType_PerformSelector:
	  NSDebugMLLog(@"low",
				   @"setIVarNamed %@ in %@ %p (superClass:%@) with performSelector value:%@",
				   name_,
				   [self class],
				   self,
				   [self superclass],
				   value_);
	  [self performSelector:ivarAccess_->infos.selector
			withObject:value_];
	  break;
	case NSObjectIVarsAccessType_Invocation:
	  {
		const char* type=[[ivarAccess_->infos.invocation methodSignature] getArgumentTypeAtIndex:2];
		void* pdata=objc_atomic_malloc(objc_sizeof_type(type));
		IdToPData(type,value_,pdata);
		NSAssert([ivarAccess_->infos.invocation selector],@"No Selector in Invocation");
		[ivarAccess_->infos.invocation setTarget:self];
		[ivarAccess_->infos.invocation setArgument:pdata
					 atIndex:2];
		NSDebugMLLog(@"low",
					 @"setIVarNamed %@ in %@ %p (superClass:%@) with invocation value:%@",
					 name_,
					 [self class],
					 self,
					 [self superclass],
					 value_);
		[ivarAccess_->infos.invocation invoke];
		objc_free(pdata);
	  };
	  break;
	case NSObjectIVarsAccessType_Direct:
	  {
		const char* IVarType=ivarAccess_->infos.ivar->ivar_type;
		if (IVarType)
		  {
			unsigned int size=objc_sizeof_type(IVarType);
			void* pdata=objc_atomic_malloc(size);
			int offset = ivarAccess_->infos.ivar->ivar_offset;
			IdToPData(IVarType,value_,pdata);
			memcpy(((void*)self)+offset,pdata, size);
			objc_free(pdata);
		  }
		else
		  {
			ExceptionRaise(@"NSObject IVar",
						   @"Can't set Variable named %@ in %@ %p (superClass:%@)",
						   name_,
						   [self class],
						   self,
						   [self superclass]);
		  };
	  };
	  break;
	case NSObjectIVarsAccessType_DictionaryWithRemoveObject:
	case NSObjectIVarsAccessType_DictionaryWithoutRemoveObject:
	  if (value_ || ivarAccess_->accessType==NSObjectIVarsAccessType_DictionaryWithoutRemoveObject)
		{
		  NSDebugMLLog(@"low",
					   @"setIVarNamed %@ in %@ %p (superClass:%@) with setObjectForKey:",
					   name_,
					   [self class],
					   self,
					   [self superclass]);
		  // keyvalue coding
		  [self setObject:value_
				forKey:name_];
		}
	  else
		{
		  NSDebugMLLog(@"low",
					   @"setIVarNamed %@ in %@ %p (superClass:%@) with removeObjectForKey:",
					   name_,
					   [self class],
					   self,
					   [self superclass]);
		  // keyvalue coding
		  [self removeObjectForKey:name_];
		};
	  break;
	case NSObjectIVarsAccessType_EO:
          NSDebugMLLog(@"low",
                       @"setIVarNamed %@ in %@ %p (superClass:%@) with takeValue:forKey:",
                       name_,
                       [self class],
                       self,
                       [self superclass]);
          // keyvalue coding
          [self takeValue:value_
                forKey:name_];
	  break;
	default:
	  break;
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setIVarNamed:(NSString*)name_
		  withValue:(id)value_
{
  NSException* _exception=nil;
  BOOL _cachindEnabled=YES;
  Class _class=[self class];
  NSObjectIVarsAccess* _ivarAccess=nil;
  NSMutableDictionary* _classCache=[objectIVarAccessCache_Set objectForKey:_class];
//  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"LOG setIVarNamed:%@ withValue:%@ in %p %@ (superClass:%@)",name_,value_,self,[self class],[self superclass]);
  if (!_classCache)
	{
	  _cachindEnabled=![_class isIVarAccessCachingDisabled];
	  if (_cachindEnabled)
		{
		  if (!objectClassLock)
			objectClassLock=[NSLock new];
		  TmpLockBeforeDate(objectClassLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
		  _classCache=[NSMutableDictionary dictionary];
		  if (!objectIVarAccessCache_Set)
			objectIVarAccessCache_Set=[NSMutableDictionary new];
		  [objectIVarAccessCache_Set setObject:_classCache
									 forKey:_class];
		  TmpUnlock(objectClassLock);
		};
	};
  if (_cachindEnabled)
	_ivarAccess=[_classCache objectForKey:name_];
  if (!_ivarAccess)
	{
	  SEL sel=NULL;
	  NSDebugMLLog(@"low",@"Not ivarAccess for name:%@",name_);
	  _ivarAccess=[NSObjectIVarsAccess ivarAccess];
	  //  NSDebugMLLog(@"low",@"LOG setIVarNamed:%@ withValue:%@ in %@",name_,value_,[self class]);
	  sel=[self getSelectorWithFunctionTemplate:@"set%@:"
				forVariable:name_
				uppercaseFirstLetter:YES];
	  NSDebugMLLog(@"low",
				   @"sel=%ld (for %@ in %@)",
				   sel,name_,[self class]);
	  if (sel)
		{
		  NSMethodSignature* _sig = [self methodSignatureForSelector:sel];
		  if ([_sig numberOfArguments]!=3)
			{
			  _exception=[NSException exceptionWithName:@"NSObject IVar"
									  format:@"Can't set Variable named %@ in %@ %p (superClass:%@) (fn Bad number of Arguments)",
									  name_,
									  [self class],
									  self,
									  [self superclass]];
			}
		  else
			{
			  const char* type=[_sig getArgumentTypeAtIndex:2];
			  if (!type)
				{
				  _exception=[NSException exceptionWithName:@"NSObject IVar"
										  format:@"Can't set Variable named %@ in %@ %p (superClass:%@) (fn get argument type)",
										  name_,
										  [self class],
										  self,
										  [self superclass]];
				}
			  else
				{
				  if (*type==_C_ID)
					{
					  _ivarAccess->accessType=NSObjectIVarsAccessType_PerformSelector;	
					  _ivarAccess->infos.selector=sel;
					  NSDebugMLLog(@"low",
								   @"perform selector (IVar named :%@)",
								   name_);
					}
				  else
					{
					  NSInvocation* _invocation = [NSInvocation invocationWithMethodSignature:_sig];
					  [_invocation setSelector:sel];
					  _ivarAccess->accessType=NSObjectIVarsAccessType_Invocation;
					  _ivarAccess->infos.invocation=_invocation;
					  NSAssert([_ivarAccess->infos.invocation selector],@"No Selector in Invocation");
					  [_ivarAccess->infos.invocation retain];
					  NSDebugMLLog(@"low",
								   @"invocation (IVar named :%@)",
								   name_);
					};
				};
			};
		}
	  else
		{
		  struct objc_ivar* ivar=GSGetInstanceVariableStruct(self,name_,YES);
                  if (!ivar)
                    ivar=GSGetInstanceVariableStruct(self,name_,NO);
		  if (ivar)
			{
			  _ivarAccess->accessType=NSObjectIVarsAccessType_Direct;	
			  _ivarAccess->infos.ivar=ivar;
			  NSDebugMLLog(@"low",
						   @"direct (IVar named :%@)",
						   name_);
			}
		  else
			{
			  BOOL _respondsToSetObject=NO;
			  BOOL _respondsToRemoveObject=NO;
			  NSDebugMLLog(@"low",
						   @"setIVarNamed %@ in %@ %p (superClass:%@) with dictionary ",
						   name_,
						   [self class],
						   self,
						   [self superclass]);
			  _respondsToSetObject=[self respondsToSelector:@selector(setObject:forKey:)];
			  _respondsToRemoveObject=[self respondsToSelector:@selector(removeObjectForKey:)];
			  if (_respondsToSetObject)
				{
				  if (_respondsToRemoveObject)
					_ivarAccess->accessType=NSObjectIVarsAccessType_DictionaryWithRemoveObject;
				  else
					_ivarAccess->accessType=NSObjectIVarsAccessType_DictionaryWithoutRemoveObject;
				}
                          else
                            {
                              BOOL _respondsToTakeValue=[self respondsToSelector:@selector(takeValue:forKey:)];
                              if (_respondsToTakeValue)
                                _ivarAccess->accessType=NSObjectIVarsAccessType_EO;
                              else
				{
				  _exception=[NSException exceptionWithName:@"NSObject IVar"
										  format:@"Can't set Variable named %@ in %@ %p (superClass:%@) value=%@",
										  name_,
										  [self class],
										  self,
										  [self superclass],
										  value_];
				};
                            };
			};
		};
	  
	  if (_exception)
		_ivarAccess->accessType=NSObjectIVarsAccessType_Error;	
	  if (_cachindEnabled)
		{
		  if (!objectClassLock)
			objectClassLock=[NSLock new];
		  TmpLockBeforeDate(objectClassLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
		  [_classCache setObject:_ivarAccess
					   forKey:name_];
		  TmpUnlock(objectClassLock);
		};
	};
  if (_exception)
	[_exception raise];
  else
	[self setIVarNamed:name_
		  withValue:value_
		  withCacheObject:_ivarAccess];
//  LOGObjectFnStop();
};
#endif



//--------------------------------------------------------------------
#define PERFORM_SELECTOR_WITH_XX_VALUE	\
  id retValue=nil;																	\
  NSMethodSignature* methodSignature=[NSObject methodSignatureForSelector:_selector];  	\
  const char* retType=[methodSignature methodReturnType];	  						\
  NSInvocation* invocation= [NSInvocation invocationWithMethodSignature:methodSignature]; \
  [invocation setTarget:self];														\
  [invocation setSelector:_selector];												\
  [invocation setArgument:&_value atIndex:2];										\
  [invocation invoke];																\
  if (retType && *retType==_C_ID)									                \
	  [invocation getReturnValue:&retValue];										\
  return retValue;

//--------------------------------------------------------------------
-(id)performSelector:(SEL)_selector
		withIntValue:(int)_value
{
  PERFORM_SELECTOR_WITH_XX_VALUE
};

//--------------------------------------------------------------------
-(id)performSelector:(SEL)_selector
	  withFloatValue:(float)_value
{
  PERFORM_SELECTOR_WITH_XX_VALUE
};

//--------------------------------------------------------------------
-(id)performSelector:(SEL)_selector
	  withDoubleValue:(double)_value
{
  PERFORM_SELECTOR_WITH_XX_VALUE
};
//--------------------------------------------------------------------
-(id)performSelector:(SEL)_selector
	  withShortValue:(short)_value
{
  PERFORM_SELECTOR_WITH_XX_VALUE
};
//--------------------------------------------------------------------
-(id)performSelector:(SEL)_selector
	  withUShortValue:(ushort)_value
{
  PERFORM_SELECTOR_WITH_XX_VALUE
};

@end

