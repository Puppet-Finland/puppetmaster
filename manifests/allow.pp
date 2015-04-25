#
# == Define: puppetmaster::allow
#
# Allow connections to the puppetmaster from given IPv4/IPv6 addresses. The 
# $title of the resource is used as an identifier of the firewall rule.
#
# This define could be extended to configure fileserver.conf and auth.conf.
#
# == Parameters
#
# [*allow_address_ipv4*]
#   Allow access from this IPv4 address/network. Defaults to '127.0.0.1'. Example: '10.60.50.0/24'.
# [*allow_address_ipv6*]
#   Allow access from this IPv6 address/network. Defaults to '::1/128'. Example: 
#   '2001:0db8:85a3:0000:0000:8a2e:0370:7334'.
#
# == Examples
#
#   puppetmaster::allow { 'myfirstnode':
#       allow_address_ipv4 => '10.60.50.5',
#       allow_address_ipv6 => '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
#   }
#
define puppetmaster::allow
(
    $allow_address_ipv4='127.0.0.1',
    $allow_address_ipv6='::1/128'
)
{

    include ::puppetmaster::params

    firewall { "005 ipv4 accept from ${title} to puppetmaster":
        provider => 'iptables',
        chain    => 'INPUT',
        proto    => 'tcp',
        source   => $allow_address_ipv4,
        dport    => 8140,
        action   => 'accept',
    }

    firewall { "005 ipv6 accept from ${title} to puppetmaster":
        provider => 'ip6tables',
        chain    => 'INPUT',
        proto    => 'tcp',
        source   => $allow_address_ipv6,
        dport    => 8140,
        action   => 'accept',
    }
}
