#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

#include "Hello.h"

@implementation Hello

- (id) init
{
  [super init];

  [WOMessage setDefaultEncoding: NSUTF8StringEncoding];

  return self;
}

+(NSNumber*)sessionTimeOut
{
  return [NSNumber numberWithInt:60];
}

@end

