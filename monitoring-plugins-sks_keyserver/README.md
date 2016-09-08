Check the pool status of an own keyserver
=========================================

If you are an administrator of a public SKS server (GPG key server), you should check regulary that your server is in the SKS pool. 

This plugin for your monitoring server will help you with that as it queries (per default, URL can be adapted) the public 
sks-keyservers.net server for the given hostname and outputs not only if the server is still in the pool, but also some 
additional statistics that you might want to have at hand from time to time.

Please note that the plugin can also output the states of your peers (option: -p), so you can inform then if they are not 
in the public pool any more.

Warning and critical levels exist to configure the amount of "good" peers you want to see your server connected to at any time.

Options
-------
```
Usage:  ./check_sks_keyserver -H <hostname>  [OPTIONS]                                                                                                                  

Required option:
          -H|--hostname <FQDN> : FQDN of the host to be checked

Options:
          -w|--warning         : warn, if not more than this amount of peers is in OK state (default: 3)
          -c|--critical        : expect at least this amount of peers in OK state (default: 1)
          -p|--peer            : print information about the connected peers
          -t|--timeout         : timeout (default: 15) for the plugin itself
          -v|--version         : print version information
          -h|--help            : this help
```

Installation
------------

You can find a working RPM package for your RPM based distribution at:
 https://software.opensuse.org/package/monitoring-plugins-sks_keyserver
(.deb based distributions: please help! :-)

If you want to install only the plugin script without any further packaging overhead, please make sure to have at least 
the following Perl modules installed on your system:
* Getopt::Long
* LWP
* JSON
* JSON::Parse

You might also need to adapt the path to your utils.pm (comming from the monitoring/nagios-plugins installation) from 
```
 /usr/lib/nagios/plugins
```
to the correct path on your system.
 
Examples
--------
 
Here is an example of an NRPE command definition:
```
command[check_sks_keyserver]=/usr/lib/nagios/plugins/check_sks_keyserver -H keyserver.opensuse.org -p -c 5 -w 8
```

Contributing
------------

* Use pull requests here
* report Bugs either here or via https://bugzilla.opensuse.org/


