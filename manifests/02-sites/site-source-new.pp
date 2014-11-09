node default{
	$app_name = $::new_site_app_name

	file{"/etc/puppet/manifests/02-sites/02-site-source-${app_name}.pp":
			 ensure => present,
			 content => template("00-site-source-new.pp"),
	}
	
}
