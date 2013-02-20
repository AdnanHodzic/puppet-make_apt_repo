/*
== Definition: make_apt_repo::update
Adds a packages repository.

Parameters:
- *name*: the name of the update-upstream use in the Update field in conf/distributions
- *ensure*: present/absent, defaults to present
- *url*: a valid repository URL
- *verify_release*: check the GPG signature Releasefile
- *filter_action*: default action when something is not found in the list
- *filter_name*: a list of filenames in the format of dpkg --get-selections

Requires:
- Class["make_apt_repo"]

Example usage:

  make_apt_repo::update {"squeeze-backports":
    ensure      => present,
    repository  => "dev",
    url         => 'http://backports.debian.org/debian-backports',
    filter_name => "squeeze-backports",
  }

*/
define make_apt_repo::update (
  $suite,
  $repository,
  $url,
  $ensure = present,
  $architectures = undef,
  $verify_release = 'blindtrust',
  $filter_action = '',
  $filter_name = ''
) {

  include make_apt_repo::params

  if $filter_name != '' {
    if $filter_action == '' {
      $filter_list = "deinstall ${filter_name}-filter-list"
    } else {
      $filter_list = "${filter_action} ${filter_name}-filter-list"
    }
  } else {
    $filter_list = ''
  }

  $manage = $ensure ? {
    present => false,
    default => true,
  }

  common::concatfilepart {"update-${name}":
    ensure  => $ensure,
    manage  => $manage,
    content => template('make_apt_repo/update.erb'),
    file    => "${make_apt_repo::params::basedir}/${repository}/conf/updates",
    require => $filter_name ? {
      ''      => make_apt_repo::Repository[$repository],
      default => [
        make_apt_repo::Repository[$repository],
        make_apt_repo::Filterlist[$filter_name]
      ],
    }
  }

}
