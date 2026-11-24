This Directory contains Adaptors to different Web servers.

Currently, only the Apache2 adaptor is maintained.


Apache 24
---------

Building
~~~~~~~~

The Apache2 adaptor is built with autotools:

    cd GSWAdaptors/Apache2
    ./configure
    gmake

configure generates the GNUmakefile from GNUmakefile.in (it is not
checked in; `gmake distclean` removes it).  It locates apxs and
apr-config; if apr-config is not found, configure records the literal
string "no" in the GNUmakefile, which makes the makefile print
"no: not found" to stderr during the build.  That message is harmless:
the APR headers are found via apxs's include directory, which contains
apr-1.  If you have a separate apr-config, configure with
--with-apr-config=/path/to/apr-config to silence it.

To use the the module add:

LoadModule gsw_module   libexec/apache24/mod_gsw.so


# then somewhere down in your config:

ShowApps on

App Name=TCWebMail Instance=1 Host=127.0.0.1:9804

Then you start your App like this (plus your other arguments):

./TCWebMail.gswa/TCWebMail -WOHost 127.0.0.1 -WOPort 9804

If you enabled ShowApps, you can access the list of applications like this:

http://www.example.org/wo/showapps

If an application is unreachable the adaptor will return an HTTP status 504


Directives
----------

ShowApps on|off
    If enabled, the list of configured applications is shown at
    /wo/showapps.

App Name=<name> Instance=<n> Host=<host>:<port>
    Configures one application instance. The app is reachable under
    /wo/<name>.woa/. Instance is the number the app was started with
    (-WOPort ...). Host:port is where the app listens.

InstanceCount <number>
    The total number of application instances the module should keep
    statistics for (shared memory is sized from this). Must be at
    least as large as the number of App directives.

WOConnectTimeout <seconds>
    Timeout for connecting to the backend application. If the
    connection is not established within this time, the instance is
    treated as unreachable. Default: 5

WOWaitTimeout <seconds>
    Timeout for reading the response from the backend application.
    If the app accepts the connection but does not respond within
    this time, the request fails. Default: 60

WOMaxBodySize <bytes>
    Maximum size of a POST body the adaptor will buffer before
    forwarding it to the application. Larger requests are rejected
    with HTTP status 413. Default: 8388608 (8 MiB)

WORetryCount <number>
    How many times the adaptor retries a request whose backend
    instance was unreachable, re-resolving the app between attempts
    so the next candidate instance is tried. Default: 3

WOBalancer lowest-load|round-robin
    How unpinned requests (no instance number in the URL) are
    distributed over an app's instances. lowest-load picks the
    reachable instance with the lowest reported load; round-robin
    rotates through the instances in order, skipping unreachable or
    refusing ones. Default: lowest-load

All directives can be used in the main server config or in a
<VirtualHost> section.

dw.
