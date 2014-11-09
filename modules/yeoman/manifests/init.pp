# == Class: yeoman
#
# This class installs yeoman and it's common dependencies.
#
# === Documentation
#
# See the README
#
# === Authors
#
# Frank Carey
#
# === Copyright
#
# Copyright 2014 Frank Carey
#
class yeoman {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $yeomanPackages = ["libjpeg-turbo-progs", "optipng", "phantomjs", "python-software-properties" ]

  exec { "apt-get update" :
    command => "/usr/bin/apt-get update"
  }
  package { $yeomanPackages :
    ensure => present,
    require => Exec['apt-get update'],
  }
  package { 'compass':
    ensure   => present,
    provider => 'gem',
    require  =>  Package["rubygems"],
  }
  package { 'yo':
    ensure => present,
    provider => 'npm',
    require => Package[$yeomanPackages],
  }
  package { 'grunt-cli':
    ensure => present,
    provider => 'npm',
  }
  package { 'bower':
    ensure => present,
    provider => 'npm',
  }
}

define yeoman::generator {
  include yeoman

  package { $title :
    ensure => present,
    provider => 'npm',
  }
}

define yeoman::project($path, $repo, $generators = [], $npm_install = true, $bower_install = true, $grunt_build = true, $grunt_serve = false) {
  include yeoman

  generator{ $generators : }

  vcsrepo { $path :
      ensure   => present,
      provider => git,
      source => $repo
  }

  if $npm_install == true {
    exec { "npm install" :
      command => "npm install",
      cwd     => $path,
      require => Vcsrepo[$path],
      user => 'vagrant',
      creates => "${path}/node_modules",
      logoutput => true,
      loglevel => 'info',
      timeout => 1800,
    }
  }

  if $bower_install == true {
    exec { "bower install":
      command => "bower install --config.interactive=false",
      cwd     => $path,
      logoutput => true,
      user => 'vagrant',
      loglevel => 'info',
      require => [Exec["npm install"], Vcsrepo[$path]],
      creates => "${path}/app/bower_components",
      timeout => 1800,
    } #Do this first...
  }

  if $grunt_build == true {
  exec { "grunt build":
        command => "grunt build --force",
        cwd     => $path,
        require => [Exec["npm install", "npm install"],  Vcsrepo[$path]],
        logoutput => true,
        user => 'vagrant',
        loglevel => 'info',
        timeout => 1800,
    }  #Do this first...
  }

  if $grunt_serve == true {
    # Fix: Needs to be "properly daemonized". See https://github.com/mitchellh/vagrant/issues/1553
    exec { 'nohup grunt serve 0<&- &>/dev/null &':
          cwd     => "${projects}/angular-project",
          user => 'vagrant',
          require => [Exec["npm install", "npm install", "grunt build"],  Vcsrepo[$path]],
    }
  }
}
