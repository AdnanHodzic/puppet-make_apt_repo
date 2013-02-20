/*
== Definition: make_apt_repo::filterlist

Adds a FilterList

Parameters:
- *name*: name of the filter list
- *ensure*: present/absent, defaults to present
- *repository*: the name of the repository
- *packages*: a list of packages

Requires:
- Class["make_apt_repo"]

Example usage:

  make_apt_repo::filterlist {"lenny-backports":
    ensure     => present,
    repository => "dev",
    packages   => [
    "git install",
    "git-email install",
    "gitk install",
    ],
  }

Warning:
- Packages list have the same syntax as the output of dpkg --get-selections

*/
define make_apt_repo::filterlist (
  $repository,
  $packages,
  $ensure=present
) {

  include make_apt_repo::params

  file {"${make_apt_repo::params::basedir}/${repository}/conf/${name}-filter-list":
    ensure  => $ensure,
    owner   => 'root',
    group   => ${make_apt_repo::params::group_name},
    mode    => '0664',
    content => template('make_apt_repo/filterlist.erb'),
  }
}
