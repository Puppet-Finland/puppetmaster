#
# == Class: puppetmaster::install
#
# Install puppetserver
#
class puppetmaster::install inherits puppetmaster::params {

    package { 'puppetmaster':
        ensure => present,
        name   => $::puppetmaster::params::package_name,
    }
}
