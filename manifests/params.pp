/*

== Class: make_apt_repo::params

Global parameters

*/
class make_apt_repo::params {

  $basedir = '/var/packages'
  $ensure  = present

  case $::osfamily {
    Debian: {
      $package_name = 'make_apt_repo'
      $user_name    = 'make_apt_repo'
      $group_name   = 'make_apt_repo'
    }
  }

}
