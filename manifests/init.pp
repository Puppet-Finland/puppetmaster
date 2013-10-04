#
# == Class: puppetmaster
#
# Configure various aspects of a puppetmaster. Currently only manages 
# iptables/ip6tables rules through use of the puppetmaster::allow define.
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-lisence
# See file LICENSE for details
#
class puppetmaster {

# Rationale for this is explained in init.pp of the sshd module
if hiera('manage_puppetmaster', 'true') != 'false' {

    # Install a script used for checking a node's IP at the puppetmaster side. 
    # This is useful/necessary if using exported (firewall) resources and the 
    # $ipaddress facts are useless. This is the case, for example, when a public 
    # IP address is needed, but a private IP is returned as $ipaddress. This is 
    # the case on Amazon EC2, for example.

    file { 'puppetmaster-getip.sh':
        name => '/usr/local/bin/getip.sh',
        ensure => present,
        content => template('puppetmaster/getip.sh.erb'),
        owner => root,
        group => root,
        mode => 755,
    }
}
}
