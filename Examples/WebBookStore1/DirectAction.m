#include "DirectAction.h"
#include <WebObjects/WebObjects.h>

@implementation DirectAction : WODirectAction 

- (GSWComponent *)defaultAction 
{
    return [self pageWithName:@"Main"];
}

@end
