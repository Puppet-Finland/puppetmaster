#
# == Class: puppetmaster::monit
#
# Setups monit rules for puppetserver
#
class puppetmaster::monit
(
    $monitor_email
)
{
    monit::fragment { 'puppetmaster-puppetserver.monit':
        modulename => 'puppetmaster',
        basename   => 'puppetserver',
    }
}
