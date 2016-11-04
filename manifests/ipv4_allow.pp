#
# == Define: puppetmaster::ipv4_allow
#
# Allow connections to the puppetmaster from given IPv4 address(es).
#
# This define could be extended to configure fileserver.conf and auth.conf.
#
# == Parameters
#
# [*source*]
#   Allow access from this IPv4 address/network. Defaults to $title. Example: '10.60.50.0/24'.
#
define puppetmaster::ipv4_allow
(
    Optional[String] $source=undef
)
{

    include ::puppetmaster::params

    $ipv4_source = $source ? {
        undef   => $title,
        default => $source,
    }

    firewall { "005 ipv4 accept from ${title} to puppetmaster":
        provider => 'iptables',
        chain    => 'INPUT',
        proto    => 'tcp',
        source   => $ipv4_source,
        dport    => 8140,
        action   => 'accept',
    }
}
