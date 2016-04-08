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
#   (default) and false.
# [*puppetdb_proto*]
#   PuppetDB's protocol. Defaults to 'https', which is typically the only valid 
#   choice.
# [*puppetdb_host*]
#   Host on which PuppetDB runs. Defaults to 'puppet'.
# [*puppetdb_port*]
#   Port in which PuppetDB listens for incoming connections. Defaults to '8081', 
#   which is typically the only valid option.
# [*file_mode*]
#   Mode for managed files. Defaults to '0644'. You may want to change this if 
#   if you're setting Extended ACLs on these files - those may lure the Puppet 
#   File resource to thinking (on every run) that file permissions have changed, 
#   which in turn will trigger Puppetserver and/or PuppetDB restarts. The ACLs 
#   are very useful when several administrators must be able to edit files under 
#   /etc/puppetlabs as themselves, which is useful when /etc/puppetlabs is a Git 
#   repository and you want to ensure that commits are traceable to their real 
#   author instead of root@server.domain.com or similar.
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
    $puppetdb_proto = 'https',
    $puppetdb_host = 'puppet',
    $puppetdb_port = '8081',
    $file_mode = '0644',
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
