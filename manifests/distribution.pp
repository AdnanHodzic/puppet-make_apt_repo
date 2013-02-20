/*
== Definition: make_apt_repo::distribution

Adds a "Distribution" to manage.

Parameters:
- *ensure* present/absent, defaults to present
- *basedir* make_apt_repo basedir
- *repository*: the name of the distribution
- *origin*: package origin
- *label*: package label
- *suite*: package suite
- *architectures*: available architectures
- *components*: available components
- *description*: a short description
- *sign_with*: email of the gpg key
- *deb_indices*: file name and compression
- *dsc_indices*: file name and compression
- *update*: update policy name
- *uploaders*: who is allowed to upload packages
- *not_automatic*: automatic pined to 1 by using NotAutomatic, value are "yes" or "no"

Requires:
- Class["make_apt_repo"]

Example usage:

  make_apt_repo::distribution {"squeeze":
    ensure        => present,
    repository    => "puppet-repository",
    origin        => "eBuddy",
    label         => "eBuddy",
    suite         => "stable",
    architectures => "i386 amd64 source",
    components    => "main contrib non-free",
    description   => "Your local apt repository for use within eBuddy",
    sign_with     => "deb@ebuddy.com",
  }

*/
define make_apt_repo::distribution (
  $repository,
  $origin,
  $label,
  $suite,
  $architectures,
  $components,
  $description,
  $sign_with,
  $codename       = $name,
  $ensure         = present,
  $basedir        = $::make_apt_repo::params::basedir,
  $udebcomponents = $components,
  $deb_indices    = 'Packages Release .gz .bz2',
  $dsc_indices    = 'Sources Release .gz .bz2',
  $update         = '',
  $uploaders      = '',
  $not_automatic  = 'yes'
) {

  include make_apt_repo::params
  include concat::setup

  $notify = $ensure ? {
    present => Exec["export distribution ${name}"],
    default => undef,
  }

  concat::fragment { "distribution-${name}":
    ensure  => $ensure,
    target  => "${basedir}/${repository}/conf/distributions",
    content => template('make_apt_repo/distribution.erb'),
    notify  => $notify,
  }

  exec {"export distribution ${name}":
    command    => "su -c 'make_apt_repo -b ${basedir}/${repository} export ${codename}' make_apt_repo",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    logoutput   => on_failure,
    require     => [
      User['make_apt_repo'],
      make_apt_repo::Repository[$repository]
    ],
  }

  # Configure system for automatically adding packages
  file { "${basedir}/${repository}/tmp/${suite}":
    ensure => directory,
    mode   => '0755',
    owner  => $::make_apt_repo::params::user_name,
    group  => $::make_apt_repo::params::group_name,
  }

  cron { "${name} cron":
    command     => "cd ${basedir}/${repository}/tmp/${suite}; ls *.deb; if [ $? -eq 0 ]; then /usr/bin/make_apt_repo -b ${basedir}/${repository} includedeb ${suite} *.deb; rm *.deb; fi",
    user        => $::make_apt_repo::params::user_name,
    environment => "SHELL=/bin/bash",
    minute      => '*/5',
  }

}
