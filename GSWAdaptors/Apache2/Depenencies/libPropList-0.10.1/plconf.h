/* plconf.h:

   Contains configuration values for libPropList, and gsdd.

   */
#ifndef CONFIG_H
#define CONFIG_H

/* define MEMDEBUG if you think gsdd and / or proplist has a memory
   leak. The output this generates is VERY verbose (a line for every
   malloc / free), so you may want to pipe it into a file and run it
   through tools/findleak.tcl. */
/*#define MEMDEBUG*/

/* define DEBUG if you think something's wrong with the retain /
   release stuff. This, too, generates very verbose output. */
/* #define DEBUG */

/* The file the defaults are actually stored in. If USEMULTIPLEFILES
   is defined, this can either be an ASCII file or a directory
   containing multiple ASCII files. */
#define DEFAULTSFILE "~/GNUstep/Defaults"

/* The file gsdd stores its process id and the port it's listening on
   in. Tilde notation is supported. If this file is present, the
   library (and gsdd) will assume that there is a daemon present. */
#define PIDFILE "~/GNUstep/.AppInfo/gsdd.pid"

/* The name of the gsdd binary. The library needs this to start the
   daemon if it isn't present. Tilde notation is supported. */
#define DAEMON DAEMON_PATH

/* Port numbers. gsdd will try to bind to a port between MINPORT and
   MAXPORT. */
#define MINPORT 5000
#define MAXPORT 5100

/* The time the daemon has to start up (i.e. create PIDFILE). */
#define TIMEOUT 2

/* The signal sent to processes requesting to be kicked on domain
   change. The library handles this signal. */
#define SIGNAL SIGHUP

#endif /* CONFIG_H */
