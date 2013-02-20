/*
== Definition: make_apt_repo::repository

Adds a packages repository.

Parameters:
- *name*: the name of the repository
- *ensure*: present/absent, defaults to present
- *basedir*: base directory of make_apt_repo
- *incoming_name*: the name of the rule-set, used as argument
- *incoming_dir*: the name of the directory to scan for .changes files
- *incoming_tmpdir*: directory where the files are copied into before they are read
- *incoming_allow*: allowed distributions
- *options*: make_apt_repo options

Requires:
- Class["make_apt_repo"]

Example usage:

  make_apt_repo::repository { 'localpkgs':
    ensure  => present,
    options => ['verbose', 'basedir .'],
  }


*/
define make_apt_repo::repository (
  $ensure          = present,
  $basedir         = $::make_apt_repo::params::basedir,
  $incoming_name   = "incoming",
  $incoming_dir    = "incoming",
  $incoming_tmpdir = "tmp",
  $incoming_allow  = "",
  $options         = ['verbose', 'ask-passphrase', 'basedir .']
  ) {

  include make_apt_repo::params
  include concat::setup

  file {
    [
      "${basedir}/${name}/conf",
      "${basedir}/${name}/lists",
      "${basedir}/${name}/db",
      "${basedir}/${name}/logs",
      "${basedir}/${name}/tmp",
    ]:
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2755',
      owner   => 'make_apt_repo', 
      group   => 'make_apt_repo';
       
    [
      "${basedir}/${name}",
      "${basedir}/${name}/dists",
      "${basedir}/${name}/pool",
    ]:
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2755', 
      owner   => 'make_apt_repo', 
      group   => 'make_apt_repo';

    "${basedir}/${name}/incoming":
      ensure  => $ensure ? { present => directory, default => $ensure,},
      purge   => $ensure ? { present => undef,     default => true,}, 
      recurse => $ensure ? { present => undef,     default => true,},
      force   => $ensure ? { present => undef,     default => true,},
      mode    => '2770',
      owner   => 'make_apt_repo',
      group   => 'make_apt_repo';

    "${basedir}/${name}/conf/options":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'make_apt_repo',
      group   => 'make_apt_repo',
      content => inline_template("<%= options.join(\"\n\") %>\n");

    "${basedir}/${name}/conf/incoming":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'make_apt_repo',
      group   => 'make_apt_repo',
      content => template("make_apt_repo/incoming.erb");
  }

  concat { "${basedir}/${name}/conf/distributions":
    owner => 'make_apt_repo',
    group => 'make_apt_repo',
    mode  => '0640',
  }

}
