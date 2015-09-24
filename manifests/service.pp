#
# == Class: puppetmaster::service
#
# Configures puppetserverto start on boot
#
class puppetmaster::service inherits puppetmaster::params {

    service { 'puppetmaster':
        name    => $::puppetmaster::params::service_name,
        enable  => true,
        require => Class['puppetmaster::config'],
    }
}
