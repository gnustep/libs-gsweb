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


#import <GSWeb/GSWeb.h>

@interface HelloPage:GSWComponent 
{
    NSString *nameString;
}

- (void)setNameString:(NSString *)string;

@end
