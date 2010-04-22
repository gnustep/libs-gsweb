#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

#include "Hello.h"

@implementation Hello
+(NSNumber*)sessionTimeOut
{
  return [NSNumber numberWithInt:60];
}

@end

