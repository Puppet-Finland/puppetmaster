#
# == Class: puppetmaster::validation
#
# Add various sanity checks (e.g. ERB template syntax) to cron. If any errors 
# are found, cron will notify the admin via email.
#
# == Parameters
#
# [*check_erb*]
#   Check ERB template syntax. Valid values are 'yes' and 'no'. Defaults to 'yes'.
# [*check_pp*]
#   Check Puppet code syntax. Valid values are 'yes' and 'no'. Defaults to 'yes'.
# [*check_a_records*]
#   Check that all node certnames have valid DNS A records associated to them. 
#   Valid values are 'yes' and 'no'. Defaults to 'no'. This check is useful when 
#   using exported firewall resources and $ipaddress facts return silly values. 
#   Note that the "dig" utility is required for this check to work.
# [*dirs*]
#   A space-separated list of directories to run the syntax checks in. Defaults to 
#   '/etc/puppet'.
# [*hour*]
#   Hour(s) when the checks are run. Defaults to '12'.
# [*minute*]
#   Minute(s) when the checks are run. Defaults to '15'.
# [*weekday*]
#   Weekday(s) when the cheks are run. Defaults to * (all weekdays).
# [*email*]
#   Email address where notifications are sent. Defaults to top-scope variable
#   $::servermonitor.
#
# == Examples
#
#   class { 'puppetmaster::validation':
#       dirs => '/etc/puppet /opt/puppet',
#       email => 'puppetadmin@domain.com',
#   }
#
class puppetmaster::validation
(
    $check_erb = 'yes',
    $check_pp = 'yes',
    $check_a_records = 'no',
    $dirs = '/etc/puppet',
    $hour = '12',
    $minute = '15',
    $weekday = '*',
    $email = $::servermonitor
)
{


    ### ERB template check
    cron { 'puppetmaster-erb-check':
        ensure => $check_erb ? {
            'yes' => 'present',
            default => 'absent',
        },
        command => "find ${dirs} -name \"*.erb\" -exec sh -c \"erb -P -x -T '-' {}|ruby -c\" + > /dev/null",
        user => root,
        hour => $hour,
        minute => $minute,
        weekday => $weekday,
        environment => "MAILTO=${email}",
    }

    ### Puppet code syntax check
    cron { 'puppetmaster-pp-check':
        ensure => $check_erb ? {
            'yes' => 'present',
            default => 'absent',
        },
        command => "find ${dirs} -name \"*.pp\" -exec puppet parser validate --color=false {} + 2>&1|grep Error",
        user => root,
        hour => $hour,
        minute => $minute,
        weekday => $weekday,
        environment => "MAILTO=${email}",
    }

    ### DNS A record check

    # The check is a bit too complicated for a cron one-liner
    file { 'puppetmaster-check-a-records.sh':
        name => '/usr/local/bin/check-a-records.sh',
        ensure => $check_a_records ? {
            'yes' => 'present',
            default => 'absent',
        },
        content => template('puppetmaster/check-a-records.sh.erb'),
        owner => root,
        group => root,
        mode => 755,
    }

    cron { 'puppetmaster-a-record-check':
        ensure => $check_a_records ? {
            'yes' => 'present',
            default => 'absent',
        },
        command => '/usr/local/bin/check-a-records.sh',
        user => root,
        hour => $hour,
        minute => $minute,
        weekday => $weekday,
        environment => "MAILTO=${email}",
        require => File['puppetmaster-check-a-records.sh'],
    }



}
