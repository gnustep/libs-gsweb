#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

#include <WebObjects/WebObjects.h>

int main(int argc, const char *argv[])
{
  /* WOApplicationMain passes the arguments to process any
   default settings and instantiates the class named as the
   first parameter to make it the application object.
   This should be the name of the principal class of the application.
   The application object should implement it initialization in its
   -init method.  It will be sent -run to start the default run loop.  
   The run loop will listen for requests from the current web adaptor.  */
  int                ret=0;
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  
  ret = WOApplicationMain(@"Application", argc, argv);
  [arp release];

  return ret;
}
