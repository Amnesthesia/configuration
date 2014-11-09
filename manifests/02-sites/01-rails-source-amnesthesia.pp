node default{
	$app_name = "amnesthesia"
	$app_root = "/var/www/${app_name}"
	$app_repo = "http://github.com/Amnesthesia/Eventyr.git"

	class { "puma": } 				# Need some puma variables for this ...
	##
	### Make sure the folder for hosting iriri is set up, then fetch the latest version from git
	##
				
	file { ["/var/www/", $app_root, "${app_root}/current"]: ensure => "directory" }~>
	exec { "get_${app_name}":
    		command => "git clone ${app_repo} ${app_root}current",
    		path    => "/usr/local/bin/:/bin/:/usr/bin",
	}~>bundler::install { $app_root:
  user       => $puma::puma_user,
  	group      => $puma::www_user,
  	deployment => true,
  	without    => 'development test doc',
	}

	notify{"Cloned repository: ${app_name}":
					after => Exec["get_${app_name}"],
	}

}
