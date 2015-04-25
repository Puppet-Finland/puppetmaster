#
# == Class: puppetmaster
#
# Configure various aspects of a puppetmaster. Currently only manages 
# iptables/ip6tables rules through use of the puppetmaster::allow define.
#
#
# == Parameters
#
# [*manage*]
#  Whether to manage Puppetmaster configuration with Puppet or not. Valid values 
#  are 'yes' (default) and 'no'.
# [*allows*]
#   A hash of puppetmaster::allow resources used to allow access to the 
#   Puppetmaster through the firewall.
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
    $manage = 'yes',
    $allows = {}
)
{

if $manage == 'yes' {

    include ::puppetmaster::absent
    include ::puppetmaster::getip

    if tagged('packetfilter') {
        create_resources('puppetmaster::allow', $allows)
    }
}
}
