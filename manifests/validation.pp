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
#   An array of paths to run the syntax checks in. Defaults to ['/etc/puppet'].
# [*submodule_check*]
#   Status of Git submodule checks, such as "check if there are uncommitted 
#   changes" or "check if a submodule is ahead of its origin". Valid values are 
#   'present' and 'absent' (default). You will also have to set $submodule_dir 
#   correctly for these checks to work.
# [*submodule_dir*]
#   Location of the Puppet module directory. Defaults to 
#   '/etc/puppet/environments/production/modules'. Each Puppet module should 
#   also be a Git submodule. If $submodule_check is not 'present', then the 
#   value of this parameter has no effect.
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
#       dirs => ['/etc/puppet', '/opt/puppet'],
#       email => 'puppetadmin@domain.com',
#   }
#
class puppetmaster::validation
(
    Enum['present','absent'] $json_check = 'present',
    Enum['present','absent'] $erb_check = 'present',
    Enum['present','absent'] $pp_check = 'present',
    Enum['present','absent'] $puppet_lint_check = 'present',
    Enum['present','absent'] $submodule_check = 'absent',
    Enum['present','absent'] $a_record_check = 'absent',
    Optional[String]         $puppet_lint_opts = undef,
    $dirs = ['/etc/puppetlabs/code'],
    String                   $submodule_dir = '/etc/puppetlabs/code/environments/production/modules',
    Variant[String, Integer] $hour = '12',
    Variant[String, Integer] $minute = '15',
    Variant[String, Integer] $weekday = '*',
    String                   $email = $::servermonitor

) inherits puppetmaster::params
{
    # Convert $dirs parameter to a string
    $dirlist = join($dirs, ' ')

    $scriptdir = '/usr/local/bin'

    # Set resource defaults to avoid repetition
    File {
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
        mode  => '0755',
    }
    Cron {
        user        => $::os::params::adminuser,
        hour        => $hour,
        minute      => $minute,
        weekday     => $weekday,
        environment => ["MAILTO=${email}", 'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin'],
    }

    # Setup the interactive pvalidate.sh script which runs all these tests in 
    # the current directory.
    $json_check_line               = "${scriptdir}/check-json.sh ."
    $erb_check_line                = "${scriptdir}/check-erb.sh ."
    $pp_check_line                 = "${scriptdir}/check-pp.sh ."
    $puppet_lint_check_line        = "${scriptdir}/check-puppet-lint.sh ."
    $submodule_ahead_of_check_line = "cd ${submodule_dir} && git submodule foreach \"git status\"|grep -B 2 \"ahead of\""

    file { 'puppetmaster-pvalidate.sh':
        ensure  => present,
        name    => "${scriptdir}/pvalidate.sh",
        content => template('puppetmaster/pvalidate.sh.erb'),
    }

    # JSON check
    file { 'puppetmaster-check-json.sh':
        ensure  => present,
        name    => "${scriptdir}/check-json.sh",
        content => template('puppetmaster/check-json.sh.erb'),
    }
    cron { 'puppetmaster-json-check':
        ensure  => $json_check,
        command => "${scriptdir}/check-json.sh ${dirlist}",
    }

    # ERB check
    file { 'puppetmaster-check-erb.sh':
        ensure  => present,
        name    => "${scriptdir}/check-erb.sh",
        content => template('puppetmaster/check-erb.sh.erb'),
    }
    cron { 'puppetmaster-erb-check':
        ensure  => $erb_check,
        command => "${scriptdir}/check-erb.sh ${dirlist}",
    }

    # Puppet manifest syntax check
    file { 'puppetmaster-check-pp.sh':
        ensure  => present,
        name    => "${scriptdir}/check-pp.sh",
        content => template('puppetmaster/check-pp.sh.erb'),
    }
    cron { 'puppetmaster-pp-check':
        ensure  => $pp_check,
        command => "${scriptdir}/check-pp.sh ${dirlist}",
    }

    # puppet-lint check
    file { 'puppetmaster-check-puppet-lint.sh':
        ensure  => present,
        name    => "${scriptdir}/check-puppet-lint.sh",
        content => template('puppetmaster/check-puppet-lint.sh.erb'),
    }
    cron { 'puppetmaster-puppet-lint-check':
        ensure  => $puppet_lint_check,
        command => "${scriptdir}/check-puppet-lint.sh ${dirlist}",
    }

    # DNS A record check
    file { 'puppetmaster-check-a-records.sh':
        ensure  => present,
        name    => '/usr/local/bin/check-a-records.sh',
        content => template('puppetmaster/check-a-records.sh.erb'),
    }

    cron { 'puppetmaster-a-record-check':
        ensure  => $a_record_check,
        command => "${scriptdir}/check-a-records.sh",
    }

    # Git submodule checks
    cron { 'puppetmaster-submodule_ahead_of_check':
        ensure  => $submodule_check,
        command => $submodule_ahead_of_check_line,
    }

}
