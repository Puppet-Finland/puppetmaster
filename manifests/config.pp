#
# == Class: puppetmaster::config
#
# Configure Puppet server
#
class puppetmaster::config
(
    $puppetdb_proto,
    $puppetdb_host,
    $puppetdb_port

) inherits puppetmaster::params
{
    if $puppetdb_host {
        class { '::puppetmaster::config::puppetdb':
            puppetdb_proto => $puppetdb_proto,
            puppetdb_host  => $puppetdb_host,
            puppetdb_port  => $puppetdb_port,
        }
    }
}