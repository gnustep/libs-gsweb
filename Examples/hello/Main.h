/*
 * Main.h
 *
 * You may freely copy, distribute and reuse the code in this example.
 * Apple disclaims any warranty of any kind, expressed or implied, as to
 * its fitness for any particular use.
 *
 * This file declares the interface to the object that controls the Main 
 * page.
 */

#import <GSWeb/GSWeb.h>

@interface Main:GSWComponent 
{
  NSString *nameString;
}

- (GSWComponent *)sayHello;

@end

