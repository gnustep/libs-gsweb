#include <GSWeb/GSWeb.h>

int main(int argc, const char *argv[])
{
  /* GSWApplicationMain passes the arguments to process any
     default settings and instantiates the class named as the
     first parameter to make it the application object.
     This should be the name of the principal class of the application.
     The application object should implement it initialization in its
     -init method.  It will be sent -run to start the default run loop.  
     The run loop will listen for requests from the current web adaptor.  */

    return GSWApplicationMain(@"Application", argc, argv);
}
