#
# == Class: puppetmaster::validation
#
# Add various sanity checks (e.g. ERB template syntax) to cron. If any errors 
# are found, cron will notify the admin via email.
#
# == Parameters
#
# [*dirs*]
#   A space-separated list of directories to check. Defaults to '/etc/puppet'.
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
# class { 'puppetmaster::validation':
#   dirs => '/etc/puppet /opt/puppet',
#   email => 'puppetadmin@domain.com',
# }
#
class puppetmaster::validation
(
    $dirs = '/etc/puppet',
    $hour = '12',
    $minute = '15',
    $weekday = '*',
    $email = $::servermonitor
)
{
    cron { 'puppetmaster-erb-check':
        command => "find ${dirs} -name \"*.erb\" -exec sh -c \"erb -P -x -T '-' {}|ruby -c\" \; > /dev/null",
        user => root,
        hour => $hour,
        minute => $minute,
        weekday => $weekday,
        environment => "MAILTO=${email}",
    }
}
