# == Class: puppetlabs_apt
#
# Add Puppet Labs package apt repositories
#
# == Parameters
#
# [*enable_devel*]
#   Include development repositories for bleeding edge releases.
#   Default: false
#
class puppetlabs_apt(
  $enable_devel = false,
  $enable_collection = false,
  $release = $::lsbdistcodename,
) {
  include '::apt'

  if $::osfamily != 'Debian' {
    fail("${::module_name} only supports Debian based operating systems, not '${::osfamily}'")
  }

  if $release == undef {
    fail('Failed to determine the release codename')
  }

  $repo_list = $enable_devel ? {
    true => $enable_collection ? {
      true  => 'main dependencies devel PC1',
      false => 'main dependencies devel',
    },
    false => $enable_collection ? {
      true  => 'main dependencies PC1',
      false => 'main dependencies',
    },
  }

  case $release {
    'jessie': {
      if $enable_collection {
        $_release = $release
      } else {
        notify { 'Puppet Labs only supports the PC1 dist.  Please set enable_collection => true': }
      }
    }
    'stretch': {
      $_release = 'wheezy'
      notify { "Puppet Labs does not *yet* provide packages for ${release}": }
    }
    default: {
      $_release = $release
    }
  }

  apt::source { 'puppetlabs':
    location => 'http://apt.puppetlabs.com/',
    repos    => $repo_list,
    release  => $_release,
    pin      => '550',
    key      => {
      'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      'server' => 'pgp.mit.edu',
    },
  }

  package { 'puppetlabs-release':
    ensure  => installed,
    require => Apt::Source['puppetlabs'],
  }

  if $enable_collection {
    package { 'puppetlabs-release-pc1':
      ensure  => installed,
      require => Apt::Source['puppetlabs'],
    }
  }
}

