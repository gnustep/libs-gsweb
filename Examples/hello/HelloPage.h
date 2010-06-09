/*
 * HelloPage.h
 *
 * You may freely copy, distribute and reuse the code in this example.
 * We disclaims any warranty of any kind, expressed or implied, as to
 * its fitness for any particular use.
 *
 * This file declares the interface to the object that controls the Hello 
 * page.
 */

#ifndef __HelloPage_h__
#define __HelloPage_h__

#include <WebObjects/WebObjects.h>

@interface HelloPage:WOComponent 
{
    NSString *nameString;
}

- (void)setNameString:(NSString *)string;

@end

#endif // __HelloPage_h__
