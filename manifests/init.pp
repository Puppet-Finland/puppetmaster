#
# == Class: puppetmaster
#
# Configure various aspects of a puppetmaster. Most of the functionality only 
# works on Puppet 4 servers.
#
# == Parameters
#
# [*manage*]
#   Whether to manage Puppetmaster configuration with Puppet or not. Valid values 
#   are true and false.
# [*manage_puppetdb*]
#   Manage PuppetDB configuration for the Puppetmaster. Valid values are true 
#   and false (default).
# [*manage_acls*]
#   Manage Extended ACLs for /etc/puppetlabs. Valid values are true (default)
#   and false. See manifests/acl.pp for details and rationale.
# [*acl_group*]
#   The system group for which to grant access to /etc/puppetlabs. Defaults to
#   $::os::params::sudogroup.
# [*puppetdb_proto*]
#   PuppetDB's protocol. Defaults to 'https', which is typically the only valid 
#   choice.
# [*puppetdb_host*]
#   Host on which PuppetDB runs. Defaults to 'puppet'.
# [*puppetdb_port*]
#   Port in which PuppetDB listens for incoming connections. Defaults to '8081', 
#   which is typically the only valid option.
# [*file_mode*]
#   Mode for managed files. Defaults to '0654'. This is somewhat unconventional,
#   but is required when using puppetmaster::acl class; without these
#   permissions the File resource thinks (on every run) that file permissions
#   have changed, which in turn will trigger Puppetserver and/or PuppetDB
#   restarts.
# [*allows*]
#   A hash of puppetmaster::allow resources used to allow access to the 
#   Puppetmaster through the firewall.
# [*monitor_email*]
#   Email where monitoring emails are sent. Defautls to top-scope variable 
#   $::servermonitor.
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class puppetmaster
(
    $manage = true,
    $manage_puppetdb = true,
    $manage_acls = false,
    $acl_group = undef,
    $puppetdb_proto = 'https',
    $puppetdb_host = 'puppet',
    $puppetdb_port = '8081',
    $file_mode = '0654',
    $monitor_email = $::servermonitor,
    $allows = {}
)
{

if $manage {

    include ::puppetmaster::absent
    include ::puppetmaster::getip

    class { '::puppetmaster::config':
        manage_puppetdb => $manage_puppetdb,
        puppetdb_proto  => $puppetdb_proto,
        puppetdb_host   => $puppetdb_host,
        puppetdb_port   => $puppetdb_port,
        file_mode       => $file_mode,
    }

    include ::puppetmaster::service

    if $manage_acls {
        class { '::puppetmaster::acl':
            group => $acl_group,
        }
    }

    if tagged('monit') {
        class { '::puppetmaster::monit':
            monitor_email => $monitor_email,
        }
    }

    if tagged('packetfilter') {
        create_resources('puppetmaster::allow', $allows)
    }
}
}
