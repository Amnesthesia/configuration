node default{
	$app_name = $::new_site_app_name

	file{"/etc/puppet/manifests/01-databases/02-postgresql-${app_name}.pp":
			 ensure => present,
			 content => template("00-postgresql-server-new.pp.erb"),
	}
	
}
