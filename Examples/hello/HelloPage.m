/*
 * HelloPage.m
 *
 * You may freely copy, distribute and reuse the code in this example.
 * Apple disclaims any warranty of any kind, expressed or implied, as to
 * its fitness for any particular use.
 *
 * This is the implementation file for the object that controls the Hello
 * page.
 */

#import "HelloPage.h"

@implementation HelloPage

- (void)dealloc 
{
  DESTROY(nameString);
  [super dealloc];
}

- (void)setNameString:(NSString *)string
{
  ASSIGN(nameString,string);
}

@end
