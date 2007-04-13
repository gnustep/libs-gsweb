/** GSWAssociation.m - <title>GSWeb: Class GSWAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jan 1999
   
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
#include "GSWKeyValueAssociation.h"
#include "GSWConstantValueAssociation.h"
#include "GSWBindingNameAssociation.h"
#include <math.h>

#include <limits.h>
#include <float.h>

#ifdef TCSDB
#include <TCSimpleDB/TCSimpleDB.h>
#endif
#if HAVE_GDL2
#include <EOControl/EOKeyValueCoding.h>
#endif

static NSDictionary* localMinMaxDictionary=nil;
static NSMutableDictionary* associationsHandlerClasses=nil;
static NSLock* associationsLock=nil;
static NSMutableArray* associationsLogsHandlerClasses=nil;
static Class NSNumberClass = Nil;
static Class NSStringClass = Nil;

//====================================================================
@implementation GSWAssociation

+(void)initialize
{
  if (self==[GSWAssociation class])
    {
      associationsLock=[NSLock new];
      NSNumberClass = [NSNumber class];
      NSStringClass = [NSString class];

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
  
  [super dealloc];
};

//--------------------------------------------------------------------
//	init
-(id)init
{
  if ((self=[super init]))
    {
    };
  _negate = NO;
  
  return self;
};

-(void)dealloc
{
  DESTROY(_bindingName);
  DESTROY(_declarationName);
  DESTROY(_declarationType);
  [super dealloc];
};


// YES if we negate the result before returnig it.
-(BOOL)negate
{
  return _negate;
}

-(void) setNegate:(BOOL) yn
{
  _negate = yn;
}

- (BOOL)_hasBindingInParent:(GSWComponent*) parent
{
  return YES;
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWAssociation* clone = [[isa allocWithZone:zone] init];
  clone->_debugEnabled=_debugEnabled;
  [clone setDebugEnabledForBinding:_bindingName
         declarationName:_declarationName
         declarationType:_declarationType];
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super description];
};

//--------------------------------------------------------------------
-(NSString*)bindingName
{
  return _bindingName;
};

//--------------------------------------------------------------------
-(NSString*)declarationName
{
  return _declarationName;
};

//--------------------------------------------------------------------
-(NSString*)declarationType
{
  return _declarationType;
};

//--------------------------------------------------------------------
//	isValueConstant

-(BOOL)isValueConstant 
{
  return YES;
};

//--------------------------------------------------------------------
//	isValueSettable

- (BOOL)isValueSettable 
{
  return NO;
}

- (BOOL) isValueSettableInComponent:(GSWComponent*) comp
{
  return [self isValueSettable];
}

- (BOOL) isValueConstantInComponent:(GSWComponent*) comp
{
  return [self isValueConstant];
}


//--------------------------------------------------------------------
//	setValue:inComponent:

-(void)setValue:(id)value
    inComponent:(GSWComponent*)component
{
  [self subclassResponsibility:_cmd];
};

//--------------------------------------------------------------------
//	valueInComponent:

-(id)valueInComponent:(GSWComponent*)component;
{
  return [self subclassResponsibility:_cmd];
};

// added in WO5?
// they call it booleanValueInComponent:
- (BOOL) boolValueInComponent:(GSWComponent*)component
{
  id value = [self valueInComponent: component];
  int  length = 0;
  int  intVal = 0;
  NSString * tmpStr = nil;
  
  if (! value) {
   if (_negate) {
     return YES;
   }
    return NO;
  }
  if ([value isKindOfClass: NSNumberClass]) {
   if (_negate) {
     return (! [value boolValue]);
   }  
    return [value boolValue];
  }
  if ([value isKindOfClass: NSStringClass]) {
    length = [value length];
    if ((length >= 2) && (length <= 5)) {
      tmpStr = [value lowercaseString];
      if ([tmpStr isEqual:@"no"] || [tmpStr isEqual:@"false"]  || [tmpStr isEqual:@"nil"] || [tmpStr isEqual:@"null"]) {
       if (_negate) {
         return YES;
       }      
        return NO;
      }
    }
    if ([tmpStr isEqual:@"0"]) {
       if (_negate) {
         return YES;
       }          
       return NO;
    }
    if (_negate) {
      return NO;
    }              
    return YES;
  }
  if (_negate) {
    return NO;
  }              
  
  return YES;
}


//--------------------------------------------------------------------
//	associationWithKeyPath:

+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath
{
  GSWAssociation  * newAssoc = nil;
  BOOL              doNegate = NO;
  NSString        * newPath  = keyPath;
  
  if (newPath) {
    doNegate = [newPath hasPrefix:@"!"];
    if (doNegate) {
      newPath = [newPath stringByDeletingPrefix:@"!"];
    }
    if ([newPath hasPrefix:@"^"] || (!WOStrictFlag && [newPath hasPrefix:@"~"])) {
      newAssoc = [[[GSWBindingNameAssociation alloc] initWithKeyPath: newPath] autorelease];
    } else {
      newAssoc = [[[GSWKeyValueAssociation alloc]initWithKeyPath: newPath] autorelease];
    }
    if (doNegate) {
      [newAssoc setNegate:YES];               // default is NO so we may safe a call here
    }
    return newAssoc;
  }

  return nil;
};


//--------------------------------------------------------------------
//	associationWithValue:

+(GSWAssociation*)associationWithValue:(id)value
{
  //OK
  return [[[GSWConstantValueAssociation alloc]initWithValue:value] autorelease];
};

//--------------------------------------------------------------------
//	associationFromString:
//NDFN
+(GSWAssociation*)associationFromString:(NSString*)string
{
  GSWAssociation* assoc=nil;

  if ([string length]<=0)
    assoc=[self associationWithValue:string];
  else
    {
      NSString* trimmedString=[string stringByTrimmingSpaces];
      if ([trimmedString isEqualToString:NSTYES])
        {
          assoc=[self associationWithValue:GSWNumberYes];
        }
      else if ([trimmedString isEqualToString:NSTNO])
        {
          assoc=[self associationWithValue:GSWNumberNo];
        }
      else if ([trimmedString hasPrefix:@"^"])
        {
          assoc=[self associationWithKeyPath:trimmedString];
        }
      else if ([trimmedString hasPrefix:@"\""])
        {
          if ([trimmedString hasSuffix:@"\""])
            {
              assoc=[self associationWithValue:[[trimmedString stringByDeletingPrefix:@"\""] stringByDeletingSuffix:@"\""]];
            }
          else
            {
              ExceptionRaise(@"GSWAssociation",@"String '%@' start with a \" but doesn't finish with a \"",
                             trimmedString);
            };
        }
      else if ([trimmedString hasPrefix:@"\'"])
        {
          if ([trimmedString hasSuffix:@"\'"])
            {
              assoc=[self associationWithValue:[[trimmedString stringByDeletingPrefix:@"\'"] stringByDeletingSuffix:@"\'"]];
            }
          else
            {
              ExceptionRaise(@"GSWAssociation",@"String '%@' starts with a \"'\" but does not end with a \"'\"",
                             trimmedString);
            };
        }
      else if ([trimmedString hasPrefix:@"#"])
        {
          NSString* numberString=[trimmedString stringByDeletingPrefix:@"#"];
          //char* cString=[numberString lossyCString];//TODO
          const char* cString=[numberString cString];//TODO
          char* endPtr=NULL;
          int value=strtol(cString,&endPtr,16);
          if (endPtr && *endPtr)
            {
              ExceptionRaise(@"GSWAssociation",@"String '%@' start with a '#' but doesn't countain an hexadecimal number (on %dth Character)",
                             trimmedString,
                             (int)(endPtr-cString+1));
            };
          assoc=[self associationWithValue:GSWIntNumber(value)];
        }
      else
        {
          NSNumber* limit=[localMinMaxDictionary objectForKey:trimmedString];
          if (limit)
            {
              assoc=[self associationWithValue:limit];
            }
          else
            {
              NSCharacterSet* cset=[NSCharacterSet characterSetWithCharactersInString:@"-+0123456789"];
              NSRange firstCharRange=[trimmedString rangeOfCharacterFromSet:cset
                                                    options:0
                                                    range:NSMakeRange(0,1)];

              if (firstCharRange.length==0 || firstCharRange.location!=0)
                {
                  assoc=[self associationWithKeyPath:trimmedString];
                }
              else
                {
                  //char* cString=[trimmedString lossyCString];//TODO
                  const char* cString=[trimmedString cString];//TODO
                  char* endPtr=NULL;
                  int value=strtol(cString,&endPtr,10);

                  if (endPtr && *endPtr)
                    {
                      ExceptionRaise(@"GSWAssociation",
                                     @"String '%@' must be a good number",
                                     trimmedString);
                    };
                  assoc=[self associationWithValue:GSWIntNumber(value)];
                };
            };
        };
    };
  return assoc;
};

//--------------------------------------------------------------------
+(void)setClasse:(Class)class
      forHandler:(NSString*)handler
{
  LoggedLockBeforeDate(associationsLock,GSW_LOCK_LIMIT);
  if (!associationsHandlerClasses)
    {
      if (class)
        associationsHandlerClasses=[NSMutableDictionary new];
    };
  if (class)
    [associationsHandlerClasses setObject:class
                                forKey:handler];
  else if (associationsHandlerClasses)
    [associationsHandlerClasses removeObjectForKey:handler];
  LoggedUnlock(associationsLock);
};

//--------------------------------------------------------------------
+(void)addLogHandlerClasse:(Class)class
{
  LoggedLockBeforeDate(associationsLock,GSW_LOCK_LIMIT);
  if (!associationsLogsHandlerClasses)
    {
      if (class)
        associationsLogsHandlerClasses=[NSMutableArray new];
    };
  if (class)
    [associationsLogsHandlerClasses addObject:class];
  LoggedUnlock(associationsLock);
};

//--------------------------------------------------------------------
+(void)removeLogHandlerClasse:(Class)class
{
  LoggedLockBeforeDate(associationsLock,GSW_LOCK_LIMIT);
  if (associationsHandlerClasses)
    {
      if (class)
        [associationsLogsHandlerClasses removeObject:class];
    };
  LoggedUnlock(associationsLock);
};

/*
//====================================================================
@implementation GSWAssociation (GSWAssociationOldFn)
//--------------------------------------------------------------------
//	value

-(id)value
{
  GSWContext* context=[[GSWApplication application] context];
  [self valueInComponent:GSWContext_component(context)];
};

//--------------------------------------------------------------------
//	setValue:inComponent:
//OldFn
-(void)setValue:(id)value
{
  GSWContext* context=[[GSWApplication application] context];
  [self setValue:(id)value
        inComponent:GSWContext_component(context)];
};
@end
*/
//====================================================================

//--------------------------------------------------------------------
-(BOOL)isImplementedForComponent:(NSObject*)component
{
  return YES;
};


//--------------------------------------------------------------------
-(NSString*)keyPath
{
  //OK
  [self subclassResponsibility:_cmd];
  return nil;
};

//--------------------------------------------------------------------
-(void)logValue:(id)value
         forSet:(BOOL)set
{
  if (_debugEnabled)
    {
      if (associationsLogsHandlerClasses)
        {
          LoggedLockBeforeDate(associationsLock,GSW_LOCK_LIMIT);
          NS_DURING
            {
              int i=0;
              Class class=Nil;
              int handlerCount=[associationsLogsHandlerClasses count];
              NSString* debugDescription=[self debugDescription];
              for(i=0;i<handlerCount;i++)
                {
                  class=[associationsLogsHandlerClasses objectAtIndex:i];
                  if (set)
                    [class logSetValueForDeclarationNamed:_declarationName
                           type:_declarationType
                           bindingNamed:_bindingName
                           associationDescription:debugDescription
                           value:value];
                  else
                    [class logTakeValueForDeclarationNamed:_declarationName
                           type:_declarationType
                           bindingNamed:_bindingName
                           associationDescription:debugDescription
                           value:value];
                };
            }
          NS_HANDLER
            {
              LOGException(@"%@ (%@)",localException,[localException reason]);
              LoggedUnlock(associationsLock);
              [localException raise];
            }
          NS_ENDHANDLER;
          LoggedUnlock(associationsLock);
        };
    };
};

//--------------------------------------------------------------------
-(void)logTakeValue:(id)value
{
  [self logValue:value
        forSet:NO];
};

//--------------------------------------------------------------------
-(void)logSetValue:(id)value
{
  [self logValue:value
        forSet:YES];
};

//--------------------------------------------------------------------
-(void)logSynchronizeForValue:(id)value
                  inComponent:(GSWComponent*)component
            componentToParent:(BOOL)componentToParent
{
  if (associationsHandlerClasses)
    {
      LoggedLockBeforeDate(associationsLock,GSW_LOCK_LIMIT);
      NS_DURING
        {
          int i=0;
          Class class=Nil;
          int handlerCount=[associationsLogsHandlerClasses count];
          for(i=0;i<handlerCount;i++)
            {
              class=[associationsLogsHandlerClasses objectAtIndex:i];
              if (componentToParent)
                [class	logSynchronizeComponentToParentForValue:value
                        association:self
                        inComponent:component];
              else
                [class logSynchronizeParentToComponentForValue:value
                       association:self
                       inComponent:component];
            };
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",localException,[localException reason]);
          LoggedUnlock(associationsLock);
          [localException raise];
        }
      NS_ENDHANDLER;
      LoggedUnlock(associationsLock);
    };
};

//--------------------------------------------------------------------
-(void)logSynchronizeComponentToParentForValue:(id)value
                                   inComponent:(GSWComponent*)component
{
  [self logSynchronizeForValue:value
        inComponent:component
        componentToParent:YES];
};

//--------------------------------------------------------------------
-(void)logSynchronizeParentToComponentForValue:(id)value
                                   inComponent:(GSWComponent*)component
{
  [self logSynchronizeForValue:value
        inComponent:component
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

-(void)setDebugEnabledForBinding:(NSString*)bindingName
                 declarationName:(NSString*)declarationName
                 declarationType:(NSString*)declarationType
{
  _debugEnabled=YES;
  ASSIGN(_bindingName,bindingName);
  ASSIGN(_declarationName,declarationName);
  ASSIGN(_declarationType,declarationType);
};

//--------------------------------------------------------------------
+(id)valueInComponent:(GSWComponent*)object
           forKeyPath:(NSString*)keyPath
{
  static id EONullNull=nil;
  //TODO MultiThread Protection ?
  if (!EONullNull)
    {
#ifdef HAVE_GDL2 
  EONullNull=[EONull null];
#else
#ifdef TCSDB
  EONullNull=[DBNull null];
#else
  EONullNull=[NSNull null];
#endif
#endif
    };
  id retValue=nil;
  if (keyPath && object && object!=EONullNull)
    {
#if HAVE_GDL2
      NS_DURING
        {
          retValue=[object valueForKeyPath:keyPath];
        }
      NS_HANDLER
        {
          NSLog(@"Attempt to get %@ -%@ raised an exception (%@)",
                [object class],
                keyPath,
                localException);
          localException = [localException exceptionByAddingToUserInfoKey:@"Invalid Ivars/Methods" 
                                           format:@"-[%@ %@]",
                                           [object class],
                                           keyPath];
          [localException raise];
        }
      NS_ENDHANDLER;
      if (retValue==EONullNull)
        retValue=nil;
#else
#ifdef TCSDB
      // the same as on GDL2
      NS_DURING
        {
          retValue=[object valueForKeyPath:keyPath];
        }
      NS_HANDLER
        {
          NSLog(@"Attempt to get %@ -%@ raised an exception (%@)",
                [object class],
                keyPath,
                localException);
          localException = [localException exceptionByAddingToUserInfoKey:@"Invalid Ivars/Methods"
                                           format:@"-[%@ %@]",
                                           [object class],
                                           keyPath];
          [localException raise];
        }
      NS_ENDHANDLER;
      if (retValue==EONullNull)
        retValue=nil;

#else // NO TCSDB and NO GDL2
      NSMutableArray* keys=[[keyPath componentsSeparatedByString:@"."] mutableCopy];
      id part=nil;
      Class handlerClass=Nil;
      retValue=object;
      NSAssert(retValue,@"No Component");

      while(retValue && [keys count]>0)
        {
          part=[keys objectAtIndex:0];
          [keys removeObjectAtIndex:0];

          if ([part hasPrefix:@"\""])
            {
              part=[part stringByDeletingPrefix:@"\""];
              while([keys count]>0)
                {
                  id tmpPart=[keys objectAtIndex:0];
                  [keys removeObjectAtIndex:0];
                  if ([tmpPart hasSuffix:@"\""])
                    {
                      tmpPart=[tmpPart stringByDeletingSuffix:@"\""];
                      part=[part stringByAppendingFormat:@".%@",tmpPart];
                      break;
                    }
                  else
                    part=[part stringByAppendingFormat:@".%@",tmpPart];
                }                        
            }
          handlerClass=[associationsHandlerClasses objectForKey:part];

          if (handlerClass)
            retValue=[handlerClass processValueInObject:retValue
                                   forHandler:part
                                   forKeyPath:keys];
          else if ([part isEqualToString:GSASK_Class])
            {
              Class class=Nil;
              NSAssert2([keys count]>0,@"No class name for handler %@ in %@",
                        GSASK_Class,
                        keyPath);
              part=[keys objectAtIndex:0];
              [keys removeObjectAtIndex:0];

              class=NSClassFromString(part);
              NSAssert3(class>0,@"No class named %@ for handler %@ in %@",
                        part,
                        GSASK_Class,
                        keyPath);
              if (class)
                retValue=class;
              else
                retValue=nil;
            }
          else if ([part isEqualToString:GSASK_Language])
            {
              NSArray* languages=[[GSWApp _context] languages];
              int count=[languages count];
              id v=nil;
              int i=0;
              for(i=0;!v && i<count;i++)
                {
                  id language=[languages objectAtIndex:i];
                  v=[retValue valueForKey:language];
                };
              retValue=v;
            }
          else
            {
              BOOL skipping = NO;

              NS_DURING
                {
                  retValue=[retValue valueForKey:part];
                }
              NS_HANDLER
                {
                  NSLog(@"Attempt to get %@ -%@ raised an exception (%@)",
                        [retValue class],
                        part,
                        localException);
                  localException = [localException exceptionByAddingToUserInfoKey:@"Invalid Ivars/Methods"
                                                   format:@"-[%@ %@]",[retValue class],part];
                  [localException raise];
                }
              NS_ENDHANDLER;
            };
          if (retValue==EONullNull)
            retValue=nil;
        };
#endif
#endif
    };

  return retValue;
};

//--------------------------------------------------------------------

#ifdef TCSDB
+(void)setValue:(id)value
    inComponent:(GSWComponent*)object
     forKeyPath:(NSString*)keyPath
{

  id tmpObject = nil;
  NSString *tmpKey = nil;
  
  if (keyPath) {
    NSRange       r = [keyPath rangeOfString: @"."];

    if (r.length == 0) {
      tmpObject = object;
      tmpKey = keyPath;
    } else {
      NSString  *key = [keyPath substringToIndex: r.location];
     // NSString  *path = [keyPath substringFromIndex: NSMaxRange(r)];

      //[[self valueForKey: key] smartTakeValue: anObject
  //                                 forKeyPath: path];

      tmpObject = [object valueForKey: key];
      tmpKey = [keyPath substringFromIndex: NSMaxRange(r)];
    }
    if (tmpObject) //&& [object isKindOfClass:[GSWComponent class]]
    {
      NSException* exp = [tmpObject validateValue:&value
                                           forKey:tmpKey];
      if (exp)
      {
        NSException* exception=nil;
        
        exception=[NSException exceptionWithName:@"EOValidationException"
                                          reason:[exp reason]
                                        userInfo:[NSDictionary
                                                            dictionaryWithObjectsAndKeys:
                                          (value ? value : @"nil"),@"EOValidatedObjectUserInfoKey",
                                          keyPath,@"EOValidatedPropertyUserInfoKey",
                                          nil,nil]];
        [object validationFailedWithException:exception
                                        value:value
                                      keyPath:keyPath];
      } else 
        {
        // no exception, set the value

        [tmpObject takeValue:value
                     forKey:tmpKey];
      }
    }
  }
}

#else // GDL2 or GDL1

+(void)setValue:(id)value
    inComponent:(GSWComponent*)object
     forKeyPath:(NSString*)keyPath
{
  if ([keyPath length]==0)
    {
        [NSException raise:NSInvalidArgumentException 
                     format:@"No key path when setting value %@ in object of class %@",
                     value,NSStringFromClass([object class])];
    };

#if HAVE_GDL2
  [object smartTakeValue:value
          forKeyPath:keyPath];
#else // no GDL2
  NSMutableArray* keys=[[keyPath componentsSeparatedByString:@"."] mutableCopy];
  id part=nil;
  id tmpObject=object;
  Class handlerClass=Nil;
  NSAssert(tmpObject,@"No Object");
  while(tmpObject && [keys count]>0)
    {
      part=[keys objectAtIndex:0];
      [keys removeObjectAtIndex:0];

      if ([part hasPrefix:@"\""])
        {
          part=[part stringByDeletingPrefix:@"\""];
          while([keys count]>0)
            {
              id tmpPart=[keys objectAtIndex:0];
              [keys removeObjectAtIndex:0];
              if ([tmpPart hasSuffix:@"\""])
                {
                  tmpPart=[tmpPart stringByDeletingSuffix:@"\""];
                  part=[part stringByAppendingFormat:@".%@",tmpPart];
                  break;
                }
              else
                part=[part stringByAppendingFormat:@".%@",tmpPart];
            }                        
        }
      
      handlerClass=[associationsHandlerClasses objectForKey:part];

      if (handlerClass)
        {
          tmpObject=[handlerClass processSetValue:value
                                  inObject:tmpObject
                                  forHandler:part
                                  forKeyPath:keys];
        }
      else
        {
          if ([keys count]>0)
            {
              if ([part isEqualToString:GSASK_Class])
                {
                  Class class=Nil;                      
                  NSAssert2([keys count]>0,@"No class name for handler %@ in %@",
                            GSASK_Class,
                            keyPath);
                  part=[keys objectAtIndex:0];
                  [keys removeObjectAtIndex:0];
                  class=NSClassFromString(part);
                  NSAssert3(class>0,@"No class named %@ for handler %@ in %@",
                            part,
                            GSASK_Class,
                            keyPath);
                  if (class)
                    tmpObject=class;
                  else
                    tmpObject=nil;
                }
              else 
                {
                  tmpObject=[tmpObject valueForKey:part];
                }
            }
          else
            {
              GSWLogAssertGood(tmpObject);
              [tmpObject takeValue:value
                         forKey:part];
#ifdef HAVE_GDL2
              // Turbocat
              if (tmpObject && [tmpObject isKindOfClass:[GSWComponent class]]) 
                {
                  NSException* exp = [tmpObject validateValue:&value
                                                forKey:part];
                  if (exp) 
                    {
                      NSException* exception=nil;                          
                      exception=[NSException exceptionWithName:@"EOValidationException"
                                             reason:[exp reason]
                                             userInfo:[NSDictionary 
                                                        dictionaryWithObjectsAndKeys:
                                                          (value ? value : @"nil"),@"EOValidatedObjectUserInfoKey",
                                                        keyPath,@"EOValidatedPropertyUserInfoKey",
                                                        nil,nil]];
                      [object validationFailedWithException:exception
                              value:value
                              keyPath:keyPath];
                    }
                }
#endif
              tmpObject=nil;
            };
        };
    };	  
#endif
};

#endif 

@end

//===================================================================================
@implementation NSDictionary (GSWAssociation)

-(BOOL)isAssociationDebugEnabledInComponent:(GSWComponent*)component
{
  BOOL debug=NO;
  GSWAssociation* debugAssociation=[self objectForKey:@"GSWDebug"];
  if (debugAssociation)
    {
      id value=[debugAssociation valueInComponent:component];
      debug=boolValueWithDefaultFor(value,NO);
    };
  return debug;
};
  
-(void)associationsSetDebugEnabled
{
  NSEnumerator* enumerator=nil;
  id key=nil;
  id association=nil;
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      association=[self objectForKey:key];
      [association setDebugEnabledForBinding:@""
                   declarationName:key
                   declarationType:@""];	//TODO
    };
};

-(void)associationsSetValuesFromObject:(id)from
                              inObject:(id)to
{
  NSEnumerator *enumerator = nil;
  id key=nil;
  id varValue=nil;
  id var=nil;

  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      var=[self objectForKey:key];
      if ([var isKindOfClass:[GSWAssociation class]])
        varValue=[var valueInComponent:from];
      else
        varValue=var;

      if (![key isKindOfClass:[GSWAssociation class]])
        key=[GSWAssociation associationWithKeyPath:key];
      [key setValue:varValue
            inComponent:to];
    };
};

//--------------------------------------------------------------------
-(NSDictionary*)associationsWithoutPrefix:(NSString*)prefix
                               removeFrom:(NSMutableDictionary*)removeFrom
{
  NSMutableDictionary* newAssociation=nil;
  NSEnumerator *enumerator = nil;
  id key=nil;
  id varKey=nil;
  id varKeyAssociation=nil;
  id value=nil;

  newAssociation=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      if ([key hasPrefix:prefix])
        {
          value=[self objectForKey:key];
          varKey=[key stringByDeletingPrefix:prefix];
          varKeyAssociation=[GSWAssociation associationWithKeyPath:varKey];
          [newAssociation setObject:value
                          forKey:varKeyAssociation];
          [removeFrom removeObjectForKey:key];
        };
    };
  newAssociation=[NSDictionary dictionaryWithDictionary:newAssociation];

  return newAssociation;
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryByReplacingStringsWithAssociations
{
  NSMutableDictionary* newDictionary=[NSMutableDictionary dictionary];
  NSEnumerator* enumerator=[self keyEnumerator];
  id key=nil;
  id value=nil;
  id newValue=nil;
  while ((key=[enumerator nextObject]))
    {
      value=[self objectForKey:key];
      if ([value isKindOfClass:[NSString class]])
        {
          newValue=[GSWAssociation associationFromString:value];
          NSAssert(newValue,@"Nil value");
        }
      else if ([value isKindOfClass:[NSArray class]])
        {
          newValue=[value arrayByReplacingStringsWithAssociations];
          NSAssert(newValue,@"Nil value");
        }
      else if ([value isKindOfClass:[NSDictionary class]])
        {
          newValue=[value dictionaryByReplacingStringsWithAssociations];
          NSAssert(newValue,@"Nil value");
        }
      else
        newValue=value;
      [newDictionary setObject:newValue
                     forKey:key];
    };
  return [NSDictionary dictionaryWithDictionary:newDictionary];
};

@end

//===================================================================================
@implementation NSArray (GSWAssociation)
-(NSArray*)arrayByReplacingStringsWithAssociations
{
  NSMutableArray* newArray=[NSMutableArray array];
  int count=[self count];
  int i=0;
  id value=nil;
  id newValue=nil;
  for(i=0;i<count;i++)
    {
      value=[self objectAtIndex:i];
      if ([value isKindOfClass:[NSString class]])
        {
          newValue=[GSWAssociation associationFromString:value];
        }
      else if ([value isKindOfClass:[NSArray class]])
        {
          newValue=[value arrayByReplacingStringsWithAssociations];
        }
      else if ([value isKindOfClass:[NSDictionary class]])
        {
          newValue=[value dictionaryByReplacingStringsWithAssociations];
        }
      else
        newValue=value;
      [newArray addObject:newValue];
    };
  return [NSArray arrayWithArray:newArray];
};
@end
