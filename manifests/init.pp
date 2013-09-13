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

    # This class does nothing at the moment, but is still needed for the 
    # puppetmaster::allow define.

}
}
