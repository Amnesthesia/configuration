node default{
	$db_user = "amnesthesia"
	$db_pw = "${::database_amnesthesia_pw}"

	class { 'postgresql::server': } # Install PostgreSQL
	
	postgresql::server::db { "amnesthesia_production":
  						user => $db_user,
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "amnesthesia_development":
  						user => "${db_user}_dev",
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "amnesthesia_testing":
  						user => "${db_user}_test",
               password => postgresql_password($db_user, $db_pw),
  }
}
