class owncloud::webserver {
  include owncloud::params
  include jfryman::nginx

  class { 'nginx': }

  nginx::resource::vhost { 'datacenter.3logic.it' :
    ensure   => present,
    www_root => '/var/www/datacenter',
  }
}