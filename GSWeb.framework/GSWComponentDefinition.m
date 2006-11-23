/** GSWComponentDefinition.m - <title>GSWeb: Class GSWComponentDefinition</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include "GSWeb.h"

//====================================================================

/* Static variables */

static NSLock *       ComponentConstructorLock;
static NSLock *       TemplateLock;
static GSWContext *   TheTemporaryContext;
static BOOL _IsEventLoggingEnabled; // needed?

@implementation GSWComponentDefinition

+ (void) initialize
{
  if (self == [GSWComponentDefinition class]) {
    ComponentConstructorLock = [[NSLock alloc] init];
    TemplateLock = [[NSLock alloc] init];
    TheTemporaryContext = nil; 
  }
}

// that Method is used INTERNAL.
+ (GSWContext *) TheTemporaryContext
{
  return TheTemporaryContext;
}

//--------------------------------------------------------------------

#warning CHECKME: missing Languages?
// we my have a different name and class?
//  aName StartPage
//  aPath   /Users/dave/projects/new/PBXBilling/trunk/PBX.gswa/Resources/StartPage.wo
//  baseURL /WebObjects/PBX.gswa/Resources/StartPage.wo

-(id)initWithName:(NSString*)aName
             path:(NSString*)aPath
          baseURL:(NSString*)baseURL
    frameworkName:(NSString*)aFrameworkName
{
  NSString * myBasePath = nil;
  NSFileManager * defaultFileManager = nil;

  [super init];
  ASSIGN(_name, [aName stringByDeletingPathExtension]);    // does it ever happen that
  ASSIGN(_className, aName);                               // those are different? dw.
  _componentClass = NSClassFromString(_className);  
  ASSIGN(_path, aPath);   
  ASSIGN(_url, baseURL);   
  ASSIGN(_frameworkName, aFrameworkName);   
  DESTROY(_language);
  _hasBeenAccessed = NO;
  _hasContextConstructor = NO;
  _isStateless = NO;
  DESTROY(_instancePool);
  _instancePool = [NSMutableArray new];
  _lockInstancePool = [GSWApp isConcurrentRequestHandlingEnabled];
  if ((_name != nil) && (_frameworkName != nil)) {
//    NSBundle * nsbundle = [NSBundle bundleForName:_frameworkName];
// HACK! dw
    NSBundle * nsbundle = [NSBundle bundleForClass:NSClassFromString(_className)];
    if (nsbundle != nil) {
      _componentClass = NSClassFromString(_className);
    }
    // TODO: what if classname is nil?
  }
  myBasePath = [aPath stringByAppendingPathComponent: aName];
  ASSIGN(_htmlPath,[myBasePath stringByAppendingPathExtension:@"html"]);
  ASSIGN(_wodPath,[myBasePath stringByAppendingPathExtension:GSWComponentDeclarationsSuffix[GSWebNamingConv]]);
  ASSIGN(_wooPath,[myBasePath stringByAppendingPathExtension:GSWArchiveSuffix[GSWebNamingConv]]);

  defaultFileManager = [NSFileManager defaultManager];

  if (([defaultFileManager fileExistsAtPath: _htmlPath] == NO) ||
      ([defaultFileManager fileExistsAtPath: _wodPath] == NO) ||
      ([defaultFileManager fileExistsAtPath: _wooPath] == NO) ||
      (_componentClass == Nil)) {

      [NSException raise:NSInvalidArgumentException
                  format:@"%s: No template found for component named '%@'",
                         __PRETTY_FUNCTION__, _name];
  }
  _archive = nil;
  _encoding = NSUTF8StringEncoding;
  _template = nil;
  [self setCachingEnabled:[[GSWApp class] isCachingEnabled]];
  _isAwake = NO;
  if (_frameworkName == nil) {
      _bundle=[[GSWBundle alloc] initWithPath:aPath
                                 baseURL:baseURL
                                 inFrameworkNamed: nil];
  } else {
      _bundle=[[GSWBundle alloc] initWithPath:aPath
                                 baseURL:baseURL
                                 inFrameworkNamed: _frameworkName];
    if (_bundle == nil)
    {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: No framework named '%@'",
                         __PRETTY_FUNCTION__, _frameworkName];
    }
  }

  _instancePoolLock = [[NSLock alloc] init];
  
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_name);
  DESTROY(_path);
  DESTROY(_url);
  DESTROY(_frameworkName);
  DESTROY(_language);
  DESTROY(_className);
  _componentClass = Nil;
  DESTROY(_template);
  DESTROY(_htmlPath);
  DESTROY(_wodPath);
  DESTROY(_wooPath);
  DESTROY(_archive);
  DESTROY(_bundle);
  DESTROY(_sharedInstance);
  DESTROY(_instancePool);
  
  [super dealloc];

};


//--------------------------------------------------------------------

- (void) checkInComponentInstance:(GSWComponent*) component
{
  if (_sharedInstance == nil)
  {
    _sharedInstance = component;
  } else
  {
    [_instancePool addObject:component];
  }
}

- (void) _checkInComponentInstance:(GSWComponent*) component
{
  BOOL locked = NO;
  
  if (_lockInstancePool) {
    NS_DURING
      [_instancePoolLock lock];
        locked = YES;
        [self checkInComponentInstance: component];
        locked = NO;
      [_instancePoolLock unlock];    

    NS_HANDLER
     if (locked) {
        [_instancePoolLock unlock];     
     }
     localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                              __PRETTY_FUNCTION__];
     [localException raise];
    NS_ENDHANDLER;

  } else {
      [self checkInComponentInstance: component];
  }
}

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return _frameworkName;
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return _url;
}

//--------------------------------------------------------------------
-(NSString*)path
{
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return _name;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  return [NSString stringWithFormat:@"<%s %p - name:[%@] bundle:[%@] frameworkName=[%@] componentClass=[%@] isCachingEnabled=[%s] isAwake=[%s]>",
				   object_get_class_name(self),
				   (void*)self,
				   _name,
				   _bundle,
				   _frameworkName,
				   _componentClass,
				   _caching ? "YES" : "NO",
				   _isAwake ? "YES" : "NO"];
};

//--------------------------------------------------------------------
-(void)sleep
{
  //OK
  _isAwake=NO;
};

//--------------------------------------------------------------------
// dw
-(void)awake
{
  if (!_isAwake) {
    _isAwake = YES;
    if (! _caching) {
      [self componentClass];
    }
  }
};


//--------------------------------------------------------------------
-(BOOL)isCachingEnabled
{
  return _caching;
};

//--------------------------------------------------------------------
-(void)setCachingEnabled:(BOOL)flag
{
  _caching = flag;
};


//--------------------------------------------------------------------
-(void)_clearCache
{
  //OK
  [_bundle clearCache];
};

//--------------------------------------------------------------------
-(GSWElement*)templateWithName:(NSString*)aName
                     languages:(NSArray*)languages
{
  GSWElement* element=nil;

  element=[_bundle templateNamed:aName
                   languages:languages];

  return element;
};
/*
//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key
inTableNamed:(NSString*)aName
withDefaultValue:(NSString*)defaultValue
languages:(NSArray*)languages
{
  NSString* string=nil;
  LOGObjectFnStart();
  string=[_bundle stringForKey:key
  inTableNamed:aName
  withDefaultValue:defaultValue
  languages:languages];
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages
{
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  stringsTable=[bundle stringsTableNamed:aName
				  withLanguages:languages];
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages
{
  NSArray* stringsTableArray=nil;
  LOGObjectFnStart();
  stringsTableArray=[bundle stringsTableArrayNamed:aName
						withLanguages:languages];
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)aName
						 ofType:(NSString*)type
					  languages:(NSArray*)languages
						request:(GSWRequest*)request
{
  NSString* url=nil;
  LOGObjectFnStart();
  url=[bundle urlForResourceNamed:aName
				  ofType:type
				  languages:languages
				  request:request];
  LOGObjectFnStop();
  return url;
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)languages
{
  NSString* path=nil;

  path=[_bundle pathForResourceNamed:aName
                ofType:aType
                languages:languages];

  return path;
};


#warning CHECKME

-(GSWComponent*) _componentInstanceInContext:(GSWContext*) aContext
{
  Class myClass = [self componentClass];
  GSWComponent * component = nil;
  IMP           instanceInitIMP = NULL;
  IMP           componentInitIMP = NULL;
  GSWComponent * myInstance = nil;
  BOOL         locked = NO;
  
  if ([myClass isKindOfClass: [GSWComponent class]]) {
    [aContext _setComponentName:_className];
  }
  [aContext _setTempComponentDefinition:self];

  NS_DURING

    if (!_hasBeenAccessed) {
        myInstance = [myClass alloc];
        instanceInitIMP = [myInstance methodForSelector:@selector(init)];
        componentInitIMP = [GSWComponent instanceMethodForSelector:@selector(init)];
  
        if (instanceInitIMP != componentInitIMP) {
//          NSLog(@"Class %s should implement initWithContext: and not init", object_get_class_name(myClass));
          [ComponentConstructorLock lock];
            locked = YES;
            TheTemporaryContext = aContext;
            component = AUTORELEASE([myInstance init]);
            TheTemporaryContext = nil;          
            locked = NO;
            _hasContextConstructor = NO;
          [ComponentConstructorLock unlock];
        } else {     
          component = AUTORELEASE([myInstance initWithContext: aContext]);
          _hasContextConstructor = YES;
        }
    } else {
    // check if we can use some intelligent caching here. 
        myInstance = [myClass alloc];
  
        if (_hasContextConstructor == NO) {
          [ComponentConstructorLock lock];
            locked = YES;
            TheTemporaryContext = aContext;
            component = AUTORELEASE([myInstance init]);
            TheTemporaryContext = nil;          
            locked = NO;
          [ComponentConstructorLock unlock];
        } else {     
          component = AUTORELEASE([myInstance initWithContext: aContext]);
        }
    }
  NS_HANDLER
      if (locked) {
         [ComponentConstructorLock unlock];     
      }
      localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                            __PRETTY_FUNCTION__];
      LOGException(@"exception=%@",localException);
      [localException raise];
  NS_ENDHANDLER;
  
  if ([component context] == nil) {
      [NSException raise:NSInvalidArgumentException
                format:@"Component '%@' was not properly initialized. Make sure [super initWithContext:] is called. In %s",
                        _className,
                        __PRETTY_FUNCTION__];
  }
  return component;
}

- (BOOL) isStateless
{
  return _isStateless;
}


// this is called when we are already holding a lock.

-(GSWComponent*) _sharedInstanceInContext:(GSWContext*)aContext
{
  GSWComponent * component = nil;
  
  if (_sharedInstance != nil) {
    component = _sharedInstance;
    _sharedInstance = nil;
  } else {
    if ([_instancePool count] > 0) {
      component = AUTORELEASE(RETAIN([_instancePool lastObject]));
      [_instancePool removeLastObject];
    } else {
      component = [self _componentInstanceInContext:aContext];
    }
  }
  return component;
}


//--------------------------------------------------------------------
-(GSWComponent*)componentInstanceInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  BOOL          locked = NO;

  if (aContext == nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"Attempt to create component instance without a context. In %s",
                       __PRETTY_FUNCTION__];
  }

  NS_DURING

   if (!_hasBeenAccessed) {
     component = [self _componentInstanceInContext: aContext];
     _isStateless = [component isStateless];
     _hasBeenAccessed = YES;
   } else {
     if (_isStateless) {
       if (_lockInstancePool) {
        [_instancePoolLock lock];
           locked = YES;
           component = [self _sharedInstanceInContext:aContext];
           locked = NO;        
        [_instancePoolLock unlock];
       } else {
         component = [self _sharedInstanceInContext:aContext];
       }
     } else {
       component = [self _componentInstanceInContext:aContext];
     }
   }

  NS_HANDLER

   localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                    __PRETTY_FUNCTION__];
   LOGException(@"exception=%@",localException);
   if (_lockInstancePool && locked) {
     [_instancePoolLock unlock];
   }
   [localException raise];

  NS_ENDHANDLER;
   
   return component;
}


//--------------------------------------------------------------------
/** Find the class of the component **/
-(Class) componentClass
{  
  Class componentClass = Nil;
  
  if (_componentClass) {
    return _componentClass;
  }
  
  componentClass = _componentClass;
  if (!componentClass) {
    componentClass=NSClassFromString(_name);//???
  }
  if (!componentClass) // There's no class with that name
    {
      BOOL createClassesOk=NO;
      NSString* superClassName=nil;
      if (!WOStrictFlag)
        {
          // Search component archive for a superclass (superClassName keyword)
          NSDictionary* archive=[_bundle archiveNamed:_name];
          superClassName=[archive objectForKey:@"superClassName"];
          if (superClassName)
            {
              if (!NSClassFromString(superClassName))
                {
                  ExceptionRaise(NSGenericException,@"Superclass %@ of component %@ doesn't exist",
                                 superClassName,
                                 _name);
                };
            };
        };
      // If we haven't found a superclass, use GSWComponent as the superclass
      if (!superClassName)
        superClassName=@"GSWComponent";
      // Create class
      createClassesOk=[GSWApplication createUnknownComponentClasses:[NSArray arrayWithObject:_name]
                                      superClassName:superClassName];

      // Use it
      componentClass=NSClassFromString(_name);
    };
  //call GSWApp isCaching
  _componentClass=componentClass;

  return componentClass;
};

//--------------------------------------------------------------------
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)associations
                                                   template:(GSWElement*)template
{
  //OK
  GSWComponentReference* componentReference=nil;
  LOGObjectFnStart();
  componentReference=[[[GSWComponentReference alloc]initWithName:_name
                                                    associations:associations
                                                    template:template] autorelease];
  LOGObjectFnStop();
  return componentReference;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)componentAPI
{
  NSDictionary* componentAPI=nil;
  componentAPI=[_bundle apiNamed:_name];

  return componentAPI;
};


//--------------------------------------------------------------------
-(void) finishInitializingComponent:(GSWComponent*)component
{
  //OK
  NSDictionary* archive=nil;
  archive=[_bundle archiveNamed:_name];
  [_bundle initializeObject:component
           fromArchive:archive];
};


//--------------------------------------------------------------------
-(void)_notifyObserversForDyingComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeObserversForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_registerObserver:(id)observer
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)_registerObserver:(id)observer
{
  LOGClassFnNotImplemented();	//TODOFN
};

- (GSWElement *) template
{
  BOOL htmlChangedOnDisk = NO;
  BOOL wodChangedOnDisk = NO;
  BOOL doCache = [self isCachingEnabled];

  if (doCache == NO) {
    htmlChangedOnDisk = YES; // todo compare last chage date with load date
    if (_htmlPath != nil && !htmlChangedOnDisk) {
      wodChangedOnDisk = YES; // todo compare last chage date with load date
    }
  }
  
  if (_htmlPath != nil && (_template == nil || htmlChangedOnDisk || wodChangedOnDisk)) {
  NS_DURING
    [TemplateLock lock];
    DESTROY(_template);
  
    _template = RETAIN([_bundle templateNamed: _name
                                    languages:nil]); // _language? array?
    [TemplateLock unlock];
  NS_HANDLER
    DESTROY(_template);
    [TemplateLock unlock];
    [localException raise];
  NS_ENDHANDLER

  }
  return _template;
}

@end
