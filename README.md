# puppetmaster

A puppet module for managing some aspects of puppetmaster configuration. 
Currnetly the module is focused on support tasks such as cleaning up old 
reports, opening holes in the firewall and validating .erb and .pp file syntaces 
automatically.

# Module usage

* [Class: puppetmaster](manifests/init.pp)
* [Class: puppetmaster::cleanup](manifests/cleanup.pp)
* [Class: puppetmaster::validation](manifests/validation.pp)
* [Define: puppetmaster::allow](manifests/allow.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on

* Debian 7
* Ubuntu 12.04
* CentOS 6

It should work with minor modifications on any *NIX-like operating system.

For details see [params.pp](manifests/params.pp).
