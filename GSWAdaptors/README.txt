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

There is also a machine-readable status endpoint for scripts and monitoring
tools:

http://www.example.org/wo/status

It answers JSON with the same data as the HTML page (per-instance load,
unreachable/refusing flags, last request/response times); the app list is
only included when ShowApps is on.

If an application is unreachable the adaptor will return an HTTP status 504


Directives
----------

ShowApps on|off
    If enabled, the list of configured applications is shown at
    /wo/showapps (HTML) and /wo/status (JSON).

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

    Note: if Apache's own LimitRequestBody is set to a smaller value,
    Apache rejects the request before the adaptor ever sees it, so the
    effective limit is the smaller of the two.

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
<VirtualHost> section.  A <VirtualHost> that does not set any of them
inherits the main server config, so the usual setup is to configure the
apps and timeouts once in the main config and let every vhost inherit
them; per-vhost directives override the inherited values for that vhost
only.

The adaptor opens a fresh connection to the backend for every request and
closes it again after the response (it sends "Connection: close" to the
backend).  There is no connection pooling to the backend; that would be a
much larger change and is not planned for the near future.

dw.
