#
# == Class: puppetmaster::params
#
# Defines some variables based on the operating system
#
class puppetmaster::params {

    include ::os::params

    $confdir = '/etc/puppetlabs'
    $rundir = '/var/run/puppetlabs/'

    $package_name = 'puppetserver'
    $routes_yaml = "${confdir}/puppet/routes.yaml"
    $puppet_conf = "${confdir}/puppet/puppet.conf"
    $puppetdb_conf = "${confdir}/puppet/puppetdb.conf"
    $service_name = 'puppetserver'
    $pidfile = "${rundir}/puppetserver/puppetserver.pid"

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

    if str2bool($::has_systemd) {
        $service_start = "${::os::params::systemctl} start ${service_name}"
        $service_stop = "${::os::params::systemctl} stop ${service_name}"
    } else {
        $service_start = "${::os::params::service_cmd} ${service_name} start"
        $service_stop = "${::os::params::service_cmd} ${service_name} stop"
    }


}
