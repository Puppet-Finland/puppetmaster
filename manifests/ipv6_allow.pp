#
# == Define: puppetmaster::ipv6_allow
#
# Allow connections to the puppetmaster from given IPv6 address(es).
#
# == Parameters
#
# [*source*]
#   Allow access from this IPv6 address/network. Defaults to $title. Example: 
#   '2001:0db8:85a3:0000:0000:8a2e:0370:7334'.
#
define puppetmaster::ipv6_allow
(
    Optional[String] $source=undef
)
{

    include ::puppetmaster::params

    $ipv6_source = $source ? {
        undef   => $title,
        default => $source,
    }

    firewall { "005 ipv6 accept from ${title} to puppetmaster":
        provider => 'iptables',
        chain    => 'INPUT',
        proto    => 'tcp',
        source   => $ipv6_source,
        dport    => 8140,
        action   => 'accept',
    }
}
