#
# == Class: puppetmaster::config
#
# Configure Puppet server
#
class puppetmaster::config
(
    $manage_puppetdb,
    $puppetdb_proto,
    $puppetdb_host,
    $puppetdb_port,
    $file_mode

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
