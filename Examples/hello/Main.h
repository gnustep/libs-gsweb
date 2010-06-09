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

#ifndef __Main_h__
#define __Main_h__

#include <WebObjects/WebObjects.h>

@interface Main:GSWComponent 
{
  NSString *nameString;
}

- (GSWComponent *)sayHello;

@end

#endif // __Main_h__
