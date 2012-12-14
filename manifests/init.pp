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
  $enable_devel = false
) {

  if $osfamily != 'Debian' {
    fail("${module_name} only supports Debian based operating systems, not '${osfamily}'")
  }

  $repo_list = $enable_devel ? {
    true  => 'main dependencies devel',
    false => 'main dependencies',
  }

  apt::source { "puppetlabs":
    location   => "http://apt.puppetlabs.com/",
    key        => '4BD6EC30',
    key_source => 'http://apt.puppetlabs.com/pubkey.gpg',
    pin        => '900',
    repos      => $repo_list,
  }

  package{ "puppetlabs-release":
    ensure  => installed,
    require => Apt::Source["puppetlabs"],
  }
}
