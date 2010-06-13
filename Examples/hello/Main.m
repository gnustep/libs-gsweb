/*
 * Main.m
 *
 * You may freely copy, distribute and reuse the code in this example.
 * We disclaims any warranty of any kind, expressed or implied, as to
 * its fitness for any particular use.
 *
 * This is the implementation file for the object that controls the Main
 * page.
 */

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

#include "Main.h"
#include "Hello.h"
#include "HelloPage.h"

@implementation Main

- (void)dealloc 
{
  DESTROY(nameString);
  [super dealloc];
}

- (WOComponent *)sayHello 
{
  HelloPage *nextPage = (HelloPage*)[self pageWithName:@"HelloPage"];
  [nextPage setNameString:nameString];
  
  return nextPage;
}

@end

/*
 * in an real world application you should move these to separate files.
 */

@interface Session:WOSession
{
}

@end

@interface Application:WOApplication
{
}

@end

@interface DirectAction:WODirectAction
{
}
@end

@implementation Session
@end

@implementation Application
@end

@implementation DirectAction
@end
