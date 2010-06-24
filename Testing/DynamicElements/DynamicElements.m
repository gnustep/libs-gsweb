#include <WebObjects/WebObjects.h>
#include "DynamicElements.h"

/* Those are just empty to make the demo work.
 * In an real application, you might want to add real code to these classes
 * and split them into separate files.
 */

@implementation DynamicElements
- (id) init
{
  if ([super init]) {
    [WOMessage setDefaultEncoding: NSUTF8StringEncoding];
  }
  return self;
}

@end

@interface Session: WOSession
@end

@implementation Session
@end

@interface DirectAction: WODirectAction
@end

@implementation DirectAction
@end

