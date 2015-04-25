#
# == Class: puppetmaster::getip
#
# Add a script that can query DNS to determine the IP of a given FQDN
#
class puppetmaster::getip inherits puppetmaster::params
{
    # We need to have "dig" installed
    include ::dnsutils

    # Install a script used for checking a node's IP at the puppetmaster side.
    # This is useful/necessary if using exported (firewall) resources and the
    # $::ipaddress* facts are useless. This is the case, for example, when a
    # public IP address is needed, but a private IP is returned as $ipaddress.
    # This is the case on Amazon EC2, for example.
    #
    file { 'puppetmaster-getip.sh':
        ensure  => present,
        name    => '/usr/local/bin/getip.sh',
        content => template('puppetmaster/getip.sh.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0755',
        require => Class['dnsutils::install'],
    }
}
