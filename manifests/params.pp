#
# == Class: puppetmaster::params
#
# Defines some variables based on the operating system
#
class puppetmaster::params {

    include ::os::params

    case $::osfamily {
        'RedHat': {
            $json_check_cmd = 'python -m json.tool'
        }
        'Debian': {
            $json_check_cmd = 'json_pp -f json -t null'
        }
        default: {
            fail("Unknown operating system ${::osfamily}")
        }
    }
}
