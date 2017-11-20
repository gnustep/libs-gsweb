This Directory contains Adaptors to different Web servers.

Currently, only the Apache2 adaptor is maintained.


Apache 24
---------

To use the the module add:

LoadModule gsw_module   libexec/apache24/mod_gsw.so


# then somewhere down in your config:

ShowApps on

App Name=TCWebMail Instance=1 Host=127.0.0.1:9804


Then you start your App like this (plus your other arguments):

./TCWebMail.gswa/TCWebMail -WOHost 127.0.0.1 -WOPort 9804


dw.
