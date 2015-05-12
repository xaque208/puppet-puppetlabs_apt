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
  $release = $::lsbdistcodename
) {
  include '::apt'

  if $::osfamily != 'Debian' {
    fail("${::module_name} only supports Debian based operating systems, not '${::osfamily}'")
  }

  if $release == undef {
    fail('Failed to determine the release codename')
  }

  $repo_list = $enable_devel ? {
    true  => 'main dependencies devel',
    false => 'main dependencies',
  }

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com/',
    key        => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
    key_source => 'https://apt.puppetlabs.com/pubkey.gpg',
    pin        => '550',
    repos      => $repo_list,
    release    => $release,
  }

  package{ 'puppetlabs-release':
    ensure  => installed,
    require => Apt::Source['puppetlabs'],
  }
}

