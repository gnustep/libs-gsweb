#include "DirectAction.h"
#include <GSWeb/GSWeb.h>

@implementation DirectAction : GSWDirectAction 

- (GSWComponent *)defaultAction 
{
    return [self pageWithName:@"Main"];
}

@end
