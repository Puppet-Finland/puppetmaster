#
# == Class: puppetmaster::acl
#
# Setup ACLs in /etc/puppetlabs so that (admin) users in a certain system group 
# can edit files the files without becoming root. This is particularly useful
# when /etc/puppetlabs is a Git repository: users will be able to make commits 
# as themselves, not as "root@localhost" or something other silly.
#
# This class only works for Puppet 4 servers installed from Puppetlabs packages. 
# Only Debian/Ubuntu-based Puppetservers have been tested. This class depends on 
# the puppetfinland/setfacl module.
#
# == Parameters
#
# [*group*]
#   The system group to grant access for. Defaults to $::os::params::sudogroup:
#   "sudo" on Debian and "wheel" on RedHat.
#
# [*extra_paths*]
#   Additional paths to set ACLs for. This can, for example, be used to set ACLs
#   on .gitmodules appropriately.
#
class puppetmaster::acl
(
    Optional[String] $group = undef,
    Optional[Array[String]] $extra_paths

) inherits puppetmaster::params {

    include ::setfacl

    if $group { $l_group = $group }
    else      { $l_group = $::os::params::sudogroup }

    $basedir = '/etc/puppetlabs'

    $paths = concat(["${basedir}/code", "${basedir}/.git", "${basedir}/.gitignore"], $extra_paths)

    # Set ACLs for the files that need to be editable for all
    setfacl::target { 'etc-puppetlabs-code':
        recurse => true,
        # What wouldn't we do to keep puppet-lint happy?
        paths   => $paths,
        acls    => [    'default:mask::rwx',
                        'mask::rwx',
                        "default:g:${l_group}:rwx",
                        "g:${l_group}:rwx", ],
    }

    # Allow read-only access to Puppet configuration directories. This
    # is primarily required to keep "git status" from complaining about
    # some files in these directories from being unreadable.
    setfacl::target { 'etc-puppetlabs-configs':
        recurse => true,
        paths   => [    "${basedir}/puppet",
                        "${basedir}/puppetdb",
                        "${basedir}/puppetserver", ],
        acls    => [    'mask::rx',
                        "g:${l_group}:rx", ],

        }
}
