#
# == Class: puppetmaster::config::puppetdb
#
# Configure Puppet server to use PuppetDB
#
class puppetmaster::config::puppetdb
(
    $puppetdb_proto,
    $puppetdb_host,
    $puppetdb_port,
    $file_mode

) inherits puppetmaster::params
{

    # Reasonable resource defaults
    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
        mode  => $file_mode,
        notify  => Class['puppetmaster::service'],
    }

    Ini_setting {
        ensure  => present,
        path    => $::puppetmaster::params::puppet_conf,
        section => 'master',
        notify  => Class['puppetmaster::service'],
    }

    # Manage routes.yaml
    file { 'puppetmaster-routes.yaml':
        ensure  => present,
        name    => $::puppetmaster::params::routes_yaml,
        content => template('puppetmaster/routes.yaml.erb'),
    }

    # Selectively configure puppet.conf
    ini_setting { 'puppetmaster-storeconfigs':
        setting => 'storeconfigs',
        value   => true,
    }

    ini_setting { 'puppetmaster-storeconfigs_backend':
        setting => 'storeconfigs_backend',
        value   => 'puppetdb',
    }

    ini_setting { 'puppetmaster-reports':
        section => 'main',
        setting => 'reports',
        value   => 'store,puppetdb',
    }

    # Selectively manage puppetdb.conf
    file { 'puppetmaster-puppetdb.conf':
        ensure => file,
        name   => $::puppetmaster::params::puppetdb_conf,
    }

    ini_setting { 'puppetmaster-server_urls':
        path    => $::puppetmaster::params::puppetdb_conf,
        section => 'main',
        setting => 'server_urls',
        value   => "${puppetdb_proto}://${puppetdb_host}:${puppetdb_port}",
        require => File['puppetmaster-puppetdb.conf'],
    }
}
