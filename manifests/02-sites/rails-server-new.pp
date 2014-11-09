node default{
	$app_name = $::new_site_app_name

	file{"02-rails-server-${app_name}.pp.rb":
			 ensure => present,
			 content => template("00-rails-server-new.pp"),
	}
	
}
