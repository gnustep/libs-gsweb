/** GSWAssociation.m - <title>GSWeb: Class GSWAssociation</title>

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
#include <math.h>
#if !defined(__NetBSD__)
#include <values.h>
#endif
#ifdef TCSDB
#include <TCSimpleDB/TCSimpleDB.h>
#endif

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
  DESTROY(_bindingName);
  DESTROY(_declarationName);
  DESTROY(_declarationType);
  [super dealloc];
};

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
  GSWLogAssertGood(self);
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
-(void)setValue:(id)value
       inObject:(id)object
{
  //OK
  [self subclassResponsibility:_cmd];
};


//--------------------------------------------------------------------
//	setValue:inComponent:

-(void)setValue:(id)value
    inComponent:(GSWComponent*)component
{
  //OK
  [self setValue:value
        inObject:component];
};

//--------------------------------------------------------------------
//	valueInObject:
//NDFN
-(id)valueInObject:(id)object
{
  //OK
  return [self subclassResponsibility:_cmd];
};


//--------------------------------------------------------------------
//	valueInComponent:

-(id)valueInComponent:(GSWComponent*)component;
{
  //OK
  return [self valueInObject:component];
};


@end

//====================================================================
@implementation GSWAssociation (GSWAssociationCreation)
//--------------------------------------------------------------------
//	associationWithKeyPath:

+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath
{
  //OK
  if (keyPath)
    {
      if ([keyPath hasPrefix:@"^"]
          || (!WOStrictFlag && [keyPath hasPrefix:@"~"]))
        return [[[GSWBindingNameAssociation alloc]initWithKeyPath:keyPath] autorelease];
      else
        return [[[GSWKeyValueAssociation alloc]initWithKeyPath:keyPath] autorelease];
    }
  else
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
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"string=[%@]",string);
  if ([string length]<=0)
    assoc=[self associationWithValue:string];
  else
    {
      NSString* trimmedString=[string stringByTrimmingSpaces];
      if ([trimmedString isEqualToString:NSTYES])
        {
          assoc=[self associationWithValue:[NSNumber numberWithBool:YES]];
          NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
        }
      else if ([trimmedString isEqualToString:NSTNO])
        {
          assoc=[self associationWithValue:[NSNumber numberWithBool:NO]];
          NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
        }
      else if ([trimmedString hasPrefix:@"^"])
        {
          assoc=[self associationWithKeyPath:trimmedString];
          NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
        }
      else if ([trimmedString hasPrefix:@"\""])
        {
          if ([trimmedString hasSuffix:@"\""])
            {
              assoc=[self associationWithValue:[[trimmedString stringByDeletingPrefix:@"\""] stringByDeletingSuffix:@"\""]];
              NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
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
              NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
            }
          else
            {
              ExceptionRaise(@"GSWAssociation",@"String '%@' start with a character ' but doesn't finish with a character '",
                             trimmedString);
            };
        }
      else if ([trimmedString hasPrefix:@"#"])
        {
          NSString* numberString=[trimmedString stringByDeletingPrefix:@"#"];
          //char* cString=[numberString lossyCString];//TODO
          char* cString=[numberString cString];//TODO
          char* endPtr=NULL;
          int value=strtol(cString,&endPtr,16);
          NSDebugMLLog(@"associations",@"value=[%d]",value);
          if (endPtr && *endPtr)
            {
              ExceptionRaise(@"GSWAssociation",@"String '%@' start with a '#' but doesn't countain an hexadecimal number (on %dth Character)",
                             trimmedString,
                             (int)(endPtr-cString+1));
            };
          assoc=[self associationWithValue:[NSNumber numberWithInt:value]];
        }
      else
        {
          NSNumber* limit=[localMinMaxDictionary objectForKey:trimmedString];
          NSDebugMLLog(@"associations",@"limit=[%@]",limit);
          if (limit)
            {
              assoc=[self associationWithValue:limit];
              NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
            }
          else
            {
              NSCharacterSet* cset=[NSCharacterSet characterSetWithCharactersInString:@"-+0123456789"];
              NSRange firstCharRange=[trimmedString rangeOfCharacterFromSet:cset
                                                    options:0
                                                    range:NSMakeRange(0,1)];
              NSDebugMLLog(@"associations",@"firstCharRange.length=%d firstCharRange.location=%d ",
                           firstCharRange.length,firstCharRange.location);
              if (firstCharRange.length==0 || firstCharRange.location!=0)
                {
                  assoc=[self associationWithKeyPath:trimmedString];
                  NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
                }
              else
                {
                  //char* cString=[trimmedString lossyCString];//TODO
                  char* cString=[trimmedString cString];//TODO
                  char* endPtr=NULL;
                  int value=strtol(cString,&endPtr,10);
                  NSDebugMLLog(@"associations",@"value=[%d]",value);
                  if (endPtr && *endPtr)
                    {
                      NSDebugMLLog(@"associations",@"endPtr=[%s]",endPtr);
                      NSDebugMLLog(@"associations",@"value=[%d]",value);
                      ExceptionRaise(@"GSWAssociation",
                                     @"String '%@' must be a good number",
                                     trimmedString);
                    };
                  assoc=[self associationWithValue:[NSNumber numberWithInt:value]];
                };
            };
        };
    };
  NSDebugMLLog(@"associations",@"assoc=[%@]",assoc);
  LOGClassFnStop();
  return assoc;
};

//====================================================================
@implementation GSWAssociation (GSWAssociationHandlers)
//--------------------------------------------------------------------
+(void)setClasse:(Class)class
      forHandler:(NSString*)handler
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class=%@",class);
  NSDebugMLLog(@"associations",@"handler=%@",handler);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
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
  TmpUnlock(associationsLock);
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(void)addLogHandlerClasse:(Class)class
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class=%@",class);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
  if (!associationsLogsHandlerClasses)
    {
      if (class)
        associationsLogsHandlerClasses=[NSMutableArray new];
    };
  if (class)
    [associationsLogsHandlerClasses addObject:class];
  TmpUnlock(associationsLock);
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(void)removeLogHandlerClasse:(Class)class
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"class=%@",class);
  TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
  if (associationsHandlerClasses)
    {
      if (class)
        [associationsLogsHandlerClasses removeObject:class];
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
-(BOOL)isImplementedForComponent:(NSObject*)component
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
-(void)logValue:(id)value
         forSet:(BOOL)set
{
  if (_debugEnabled)
    {
      if (associationsLogsHandlerClasses)
        {
          TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
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
              TmpUnlock(associationsLock);
              [localException raise];
            }
          NS_ENDHANDLER;
          TmpUnlock(associationsLock);
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
                  inComponent:(NSObject*)component
            componentToParent:(BOOL)componentToParent
{
  if (associationsHandlerClasses)
    {
      TmpLockBeforeDate(associationsLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
      NS_DURING
        {
          int i=0;
          Class class=Nil;
          int handlerCount=[associationsLogsHandlerClasses count];
          NSString* debugDescription=[self debugDescription];
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
          TmpUnlock(associationsLock);
          [localException raise];
        }
      NS_ENDHANDLER;
      TmpUnlock(associationsLock);
    };
};

//--------------------------------------------------------------------
-(void)logSynchronizeComponentToParentForValue:(id)value
                                   inComponent:(NSObject*)component
{
  [self logSynchronizeForValue:value
        inComponent:component
        componentToParent:YES];
};
//--------------------------------------------------------------------
-(void)logSynchronizeParentToComponentForValue:(id)value
                                   inComponent:(NSObject*)component
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
+(id)valueInObject:(id)object
        forKeyPath:(NSString*)keyPath
{
  id retValue=nil;
#ifdef GDL2 
  id EONullNull=[EONull null];
#else
#ifdef TCSDB
  id EONullNull=[DBNull null];
#else
  id EONullNull=[NSNull null];
#endif
#endif
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: keyPath=%@ object=%p (class: %@)",
               keyPath,object,[object class]);
  if (keyPath && object && object!=EONullNull)
    {
#if GDL2
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
         // NSLog(@"GSWAssociation valueInObject:%@ forKeyPath:%@", object, keyPath);

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
          if (retValue) 
            {
              NSDebugMLLog(@"associations",@"object_get_class_name(retValue object)=%s", 
                           object_get_class_name(retValue));
            }
          NSDebugMLLog(@"associations",@"part=%@",part);
          NSDebugMLLog(@"associations",@"part class=%@",NSStringFromClass([part class]));
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
          NSDebugMLLog(@"associations",@"part=%@",part);
          handlerClass=[associationsHandlerClasses objectForKey:part];
          NSDebugMLLog(@"associations",@"_handlerClass=%@",handlerClass);
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
              NSDebugMLLog(@"associations",@"part=%@",part);
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
                  //MGNEW v=[retValue getIVarNamed:language];
                  v=[retValue valueForKey:language];
                };
              retValue=v;
            }
          else
            {
              BOOL skipping = NO;
              NSDebugMLLog(@"associations",@"call %@ valueForKey:%@",
                           [retValue class],
                           part);
              NS_DURING
                {
                  //MGNEW retValue=[retValue getIVarNamed:part];
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
  if (retValue) 
    {
      NSDebugMLLog(@"associations",@"retValue=%@",retValue);
    } 
  else 
    {
      NSDebugMLLog(@"associations",@"retValue=nil");
    }
  LOGClassFnStop();
  return retValue;
};

//--------------------------------------------------------------------

#ifdef TCSDB
+(void)setValue:(id)value
       inObject:(id)object
     forKeyPath:(NSString*)keyPath
{

  id tmpObject = nil;
  NSString *tmpKey = nil;
  
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@",value);
  NSDebugMLLog(@"associations",@"value class:%@",[value class]);
  NSDebugMLLog(@"associations",@"value String class:%@",NSStringFromClass([value class]));
  NSDebugMLLog(@"associations",@"object String class:%@",NSStringFromClass([object class]));
  NSDebugMLLog(@"associations",@"GSWAssociation: keyPath:%@",keyPath);

 // NSLog(@"GSWAssociation: setValue:%@ inObject:%@ forKeyPath:%@",value,object,keyPath);
// ... GSWAssociation: setValue:<Color (0x87be648) name=blau nr=1> inObject:<CartListComponent 0x86fa708> forKeyPath:currentCartArticle.color

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
    //NSLog(@"GSWAssociation: tmpKey:%@ tmpObject:%@",tmpKey,tmpObject);

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
      } else {
        // no exception, set the value

        [tmpObject takeValue:value
                     forKey:tmpKey];
      }
    }
  }
  LOGClassFnStop();
}

#else // GDL2 or GDL1

+(void)setValue:(id)value
       inObject:(id)object
     forKeyPath:(NSString*)keyPath
{
  LOGClassFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@",value);
  NSDebugMLLog(@"associations",@"value class:%@",[value class]);
  NSDebugMLLog(@"associations",@"value String class:%@",NSStringFromClass([value class]));
  NSDebugMLLog(@"associations",@"object String class:%@",NSStringFromClass([object class]));
  NSDebugMLLog(@"associations",@"GSWAssociation: keyPath:%@",keyPath);
  if (keyPath)
    {
#if GDL2
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
          NSDebugMLLog(@"associations",@"part=%@",part);
          NSDebugMLLog(@"associations",@"part class=%@",NSStringFromClass([part class]));
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
          NSDebugMLLog(@"associations",@"part=%@",part);
          
          handlerClass=[associationsHandlerClasses objectForKey:part];
          NSDebugMLLog(@"associations",@"handlerClass=%@",handlerClass);
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
                      NSDebugMLLog(@"associations",@"part=%@",part);
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
                  else {
                    //MGNEW tmpObject=[tmpObject getIVarNamed:part];
                    tmpObject=[tmpObject valueForKey:part];//MGNEW
                  }
                }
              else
                {
                  GSWLogAssertGood(tmpObject);
                  //MGNEW [tmpObject setIVarNamed:part
                  //	  withValue:value_];
                  [tmpObject takeValue:value
                             forKey:part];//MGNEW 
#ifdef GDL2
                  NSDebugMLLog(@"associations",@"object class=%@",[object class]);
                  NSDebugMLLog(@"associations",@"tmpObject class=%@",[tmpObject class]);
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
    }
  else
    {
      NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@ : NoKeyPath",value);
    };
  LOGClassFnStop();
};

#endif 

@end

//===================================================================================
@implementation NSDictionary (GSWAssociation)

-(BOOL)isAssociationDebugEnabledInComponent:(NSObject*)component
{
  BOOL debug=NO;
  GSWAssociation* debugAssociation=[self objectForKey:@"GSWDebug"];
  if (debugAssociation)
    {
      id value=[debugAssociation valueInObject:component];
      debug=boolValueWithDefaultFor(value,NO);
    };
  return debug;
};
  
-(void)associationsSetDebugEnabled
{
  NSEnumerator* enumerator=nil;
  id key=nil;
  id association=nil;
  LOGObjectFnStart();
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      NSDebugMLLog(@"associations",@"key=%@",key);
      association=[self objectForKey:key];
      [association setDebugEnabledForBinding:@""
                   declarationName:key
                   declarationType:@""];	//TODO
    };
  LOGObjectFnStop();
};

-(void)associationsSetValuesFromObject:(id)from
                              inObject:(id)to
{
  NSEnumerator *enumerator = nil;
  id key=nil;
  id varValue=nil;
  id var=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"from=%@",from);
  NSDebugMLLog(@"associations",@"to=%@",to);
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      NSDebugMLLog(@"associations",@"key=%@",key);
/*      NSAssert2([key isKindOfClass:[GSWAssociation class]],
                @"key is not an GSWAssociation but a %@: %@",
                [key class],
                key);*/
      var=[self objectForKey:key];
      NSDebugMLLog(@"associations",@"var=%@",var);
/*      NSAssert2([var isKindOfClass:[GSWAssociation class]],
                @"Variable is not an GSWAssociation but a %@: %@",
                [var class],
                var);*/
      if ([var isKindOfClass:[GSWAssociation class]])
        varValue=[var valueInComponent:from];
      else
        varValue=var;
      NSDebugMLLog(@"associations",@"varValue=%@",varValue);
      if (![key isKindOfClass:[GSWAssociation class]])
        key=[GSWAssociation associationWithKeyPath:key];
      [key setValue:varValue
            inComponent:to];
    };
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  newAssociation=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      NSDebugMLLog(@"associations",@"key=%@",key);
      if ([key hasPrefix:prefix])
        {
          [removeFrom removeObjectForKey:key];
          value=[self objectForKey:key];
          NSDebugMLLog(@"associations",@"value=%@",value);
          varKey=[key stringByDeletingPrefix:prefix];
          NSDebugMLLog(@"associations",@"varKey=%@",varKey);
          varKeyAssociation=[GSWAssociation associationWithKeyPath:varKey];
          NSDebugMLLog(@"associations",@"varKeyAssociation=%@",varKeyAssociation);
          [newAssociation setObject:value
                          forKey:varKeyAssociation];
        };
    };
  newAssociation=[NSDictionary dictionaryWithDictionary:newAssociation];
  LOGObjectFnStop();
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
      NSDebugMLog(@"key=%@ value=%@",key,value);
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
      NSDebugMLog(@"i=%d value=%@",i,value);
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
