#
# == Class: puppetmaster::cleanup
#
# Add various cleanup tasks to cron.
#
# == Parameters
#
# [*max_report_age*]
#   Maximum age in days for puppet agent reports. These can consume tons of 
#   diskspace, so keeping this value fairly small (1-4 weeks?) usually makes 
#   sense. Defaults to 7.
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
class puppetmaster::cleanup
(
    $max_report_age = 7,
    $hour = '12',
    $minute = '15',
    $weekday = '*',
    $email = $::servermonitor

) inherits puppetmaster::params
{
    cron { 'puppetmaster-clean-reports':
        ensure      => present,
        command     => "find /var/lib/puppet/reports -name \"*.yaml\" -mtime +${max_report_age} -exec rm -f {} \; > /dev/null",
        user        => $::os::params::adminuser,
        hour        => $hour,
        minute      => $minute,
        weekday     => $weekday,
        environment => "MAILTO=${email}",
    }
}
