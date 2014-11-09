node default{
	$username = $::new_user_username
	file{"/etc/puppet/manifests/00-system/02-user-${username}.pp":
				ensure => present,
				content => template("../templates/00-user-new.pp.erb"),
	}
}
