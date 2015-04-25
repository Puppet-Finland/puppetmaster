#
# == Class: puppetmaster::absent
#
# Remove obsolete configurations created by earlier versions of this module
#
class puppetmaster::absent inherits puppetmaster::params {

    file { 'puppetmaster-check_json.sh':
        ensure => absent,
        name   => '/usr/local/bin/check_json.sh',
    }
}
