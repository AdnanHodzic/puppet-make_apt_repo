class make_apt_repo (
  $basedir = $::make_apt_repo::params::basedir
) inherits make_apt_repo::params {

  package { $::make_apt_repo::params::package_name:
    ensure => $::make_apt_repo::params::ensure,
  }

  group { 'make_apt_repo':
    name   => $::make_apt_repo::params::group_name, 
    ensure => present,
  }

  user { 'make_apt_repo':
    name    => $::make_apt_repo::params::user_name, 
    ensure  => present,
    home    => $basedir,
    shell   => '/bin/bash',
    comment => 'make_apt_repo base directory',
    gid     => 'make_apt_repo',
    require => Group['make_apt_repo'],
  }

  file { $basedir:
    ensure  => directory,
    owner   => $::make_apt_repo::params::user_name,
    group   => $::make_apt_repo::params::group_name,
    mode    => '0755',
    require => User['make_apt_repo'],
  }

  file { "${basedir}/.gnupg":
    ensure  => directory,
    owner   => $::make_apt_repo::params::user_name,
    group   => $::make_apt_repo::params::group_name,
    mode    => '0700',
    require => File[$basedir],
  }

}

