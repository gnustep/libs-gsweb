#include <Foundation/Foundation.h>
#include <WebObjects/GSWDictionary.h>
#include <objc/runtime.h>
#include "Testing.h"

int main()
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];

//  Class gswDictClass0 = [GSWDictionary class];
  Class gswDictClass = NSClassFromString(@"GSWDictionary");

    id dict = AUTORELEASE([gswDictClass new]);

    PASS(dict != nil, "GSWDictionary dictionary created");
    PASS([dict count] == 0, "count is 0");

    NSString * helloString = @"Hello";
    
    [dict setObject:helloString
            forKeys:@"Hello.wo",@"DE", nil];

    PASS([dict count] == 1, "count is 1 after adding one object");

    id myObj = [dict objectForKeyArray:
      [NSArray arrayWithObjects: @"Hello.wo",@"DE",nil]];

    PASS([myObj isEqualTo:helloString], "objectForKeyArray works");

    myObj = [dict objectForKeyArray:
      [NSArray arrayWithObjects: @"Hello.wo",@"FR",nil]];
  
    PASS(myObj == nil, "objectForKeyArray does not find non-existing rows");
    
    [dict removeObjectForKeyArray:
      [NSArray arrayWithObjects: @"Hello.wo",@"FR",nil]];

    PASS([dict count] == 1, "count is still 1 after trying to remove one object for non-existing key");

    [dict removeObjectForKeyArray:
      [NSArray arrayWithObjects: @"Hello.wo",@"DE", nil]];

    PASS([dict count] == 0, "count is 0 after removing object using removeObjectForKeyArray:");

    [dict setObject:helloString
            forKeys:@"Hello.wo",@"IT",@"DK", nil];

    [dict removeObjectForKeys:@"Hello.wo",@"IT",@"DK", nil];

    PASS([dict count] == 0, "count is 0 after removing object using removeObjectForKeys:");

    
    //NSLog(@"%@",dict);

  
  [arp release]; arp = nil;
  return 0;
}

