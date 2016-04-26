#
# == Class: puppetmaster::config
#
# Configure Puppet server
#
class puppetmaster::config
(
    Boolean $manage_puppetdb,
    String $puppetdb_proto,
    String $puppetdb_host,
    Integer $puppetdb_port,
    String $file_mode

) inherits puppetmaster::params
{
    if $manage_puppetdb {
        class { '::puppetmaster::config::puppetdb':
            puppetdb_proto => $puppetdb_proto,
            puppetdb_host  => $puppetdb_host,
            puppetdb_port  => $puppetdb_port,
            file_mode      => $file_mode,
        }
    }
}
