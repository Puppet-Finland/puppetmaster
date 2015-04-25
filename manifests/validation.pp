#
# == Class: puppetmaster::validation
#
# Add various sanity checks (e.g. ERB template syntax) to cron. If any errors 
# are found, cron will notify the admin via email.
#
# == Parameters
#
# [*json_check*]
#   Check JSON file syntax. Valid values are 'present' and 'absent'. Defaults to 
#   'present'.
# [*erb_check*]
#   Check ERB template syntax. Valid values are 'present' and 'absent'. Defaults 
#   to 'present'.
# [*pp_check*]
#   Check Puppet manifest syntax. Valid values are 'present' and 'absent'. 
#   Defaults to 'present'.
# [*puppet_lint_check*]
#   Check Puppet manifests with puppet-lint. Valid values are 'present' and 
#   'absent'. Defaults to 'present'.
# [*puppet_lint_opts*]
#   Options to pass to puppet-lint. Undefined by default.
# [*dirs*]
#   A space-separated list of directories to run the syntax checks in. Defaults to 
#   '/etc/puppet'.
# [*a_record_check*]
#   Check that all node certnames have valid DNS A records associated to them. 
#   Valid values are 'present' and 'absent'. Defaults to 'absent'. This check is 
#   useful when using exported firewall resources and $ipaddress facts return 
#   silly values. Note that the "dig" utility is required for this check to 
#   work.
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
# == Regarding puppet-lint options ==
#
# You probably want to disable the params class inheritance check:
#
# <http://puppet-lint.com/checks/class_inherits_from_params_class>
#
# Inheriting the params class is really useful in preventing partial 
# (mis)configuration on unsupported operating systems.
#
# You may also want to disable the 80 character line check:
#
# <http://puppet-lint.com/checks/80chars/>
#
# References to $::modulename::params::some_long_variable_name are often very 
# long, let alone the command-lines that combine several of them. To make things 
# worse proper intendation adds to the line length. While splitting those long 
# lines into more manageable segments is a worthy effort, it often
#
# - Makes things _less_ readable
# - Breaks the Puppet parser
# - Adds spaces to ERB templates (and causes issues)
# - Adds spaces to resource $titles (and causes issues)
#
# Code should stay at 80 lines whenever possible, but not at any cost in my 
# opinion.
#
# To disable both of the above checks set $puppet_lint_opts to
#
# '--no-class_inherits_from_params_class-check --no-80chars-check'
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
    $json_check = 'present',
    $erb_check = 'present',
    $pp_check = 'present',
    $puppet_lint_check = 'present',
    $puppet_lint_opts = undef,
    $dirs = '/etc/puppet',
    $a_record_check = 'absent',
    $hour = '12',
    $minute = '15',
    $weekday = '*',
    $email = $::servermonitor

) inherits puppetmaster::params
{

    $scriptdir = '/usr/local/bin'

    # Set resource defaults to avoid repetition
    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
        mode => '0755',
    }
    Cron {
        user => $::os::params::adminuser,
        hour => $hour,
        minute => $minute,
        weekday => $weekday,
        environment => "MAILTO=${email}",
    }

    # Setup the interactive pvalidate.sh script which runs all these tests in 
    # the current directory.
    if $json_check == 'present'        { $json_check_line        = "${scriptdir}/check-json.sh ."        }
    if $erb_check == 'present'         { $erb_check_line         = "${scriptdir}/check-erb.sh ."         }
    if $pp_check == 'present'          { $pp_check_line          = "${scriptdir}/check-pp.sh ."          }
    if $puppet_lint_check == 'present' { $puppet_lint_check_line = "${scriptdir}/check-puppet-lint.sh ." }

    file { 'puppetmaster-pvalidate.sh':
        ensure  => present,
        name    => "${scriptdir}/pvalidate.sh",
        content => template('puppetmaster/pvalidate.sh.erb'),
    }

    # JSON check
    file { 'puppetmaster-check-json.sh':
        ensure  => $json_check,
        name    => "${scriptdir}/check-json.sh",
        content => template('puppetmaster/check-json.sh.erb'),
    }
    cron { 'puppetmaster-json-check':
        ensure  => $json_check,
        command => "${scriptdir}/check-json.sh ${dirs}",
    }

    # ERB check
    file { 'puppetmaster-check-erb.sh':
        ensure  => $erb_check,
        name    => "${scriptdir}/check-erb.sh",
        content => template('puppetmaster/check-erb.sh.erb'),
    }
    cron { 'puppetmaster-erb-check':
        ensure  => $erb_check,
        command => "${scriptdir}/check-erb.sh ${dirs}",
    }

    # Puppet manifest syntax check
    file { 'puppetmaster-check-pp.sh':
        ensure  => $pp_check,
        name    => "${scriptdir}/check-pp.sh",
        content => template('puppetmaster/check-pp.sh.erb'),
    }
    cron { 'puppetmaster-pp-check':
        ensure  => $pp_check,
        command => "${scriptdir}/check-pp.sh ${dirs}",
    }

    # puppet-lint check
    file { 'puppetmaster-check-puppet-lint.sh':
        ensure  => $puppet_lint_check,
        name    => "${scriptdir}/check-puppet-lint.sh",
        content => template('puppetmaster/check-puppet-lint.sh.erb'),
    }
    cron { 'puppetmaster-puppet-lint-check':
        ensure  => $puppet_lint_check,
        command => "${scriptdir}/check-puppet-lint.sh ${dirs}",
    }

    # DNS A record check
    file { 'puppetmaster-check-a-records.sh':
        ensure  => $a_record_check,
        name    => '/usr/local/bin/check-a-records.sh',
        content => template('puppetmaster/check-a-records.sh.erb'),
    }

    cron { 'puppetmaster-a-record-check':
        ensure  => $a_record_check,
        command => "${scriptdir}/check-a-records.sh",
    }



}
