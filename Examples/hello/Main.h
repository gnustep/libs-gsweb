/*
 * Main.h
 *
 * You may freely copy, distribute and reuse the code in this example.
 * We disclaims any warranty of any kind, expressed or implied, as to
 * its fitness for any particular use.
 *
 * This file declares the interface to the object that controls the Main 
 * page.
 */

#include <GSWeb/GSWeb.h>

@interface Main:GSWComponent 
{
  NSString *nameString;
}

- (GSWComponent *)sayHello;

@end

