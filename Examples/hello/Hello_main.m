#import <GSWeb/GSWeb.h>

int main(int argc, const char *argv[])
{
  int ret=0;
  NSAutoreleasePool     *arp = [NSAutoreleasePool new];
  ret=GSWApplicationMain(@"Hello", argc, argv);
  [arp release];
  return ret;
}
