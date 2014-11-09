node default{
	$db_user = "justbear"
	$db_pw = "${::database_justbear_pw}"

	class { 'postgresql::server': } # Install PostgreSQL
	
	postgresql::server::db { "justbear_production":
  						user => $db_user,
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "justbear_development":
  						user => "${db_user}_dev",
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "justbear_testing":
  						user => "${db_user}_test",
               password => postgresql_password($db_user, $db_pw),
  }
}
