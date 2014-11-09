node default{
	$db_user = "iririxyz"
	$db_pw = "${::database_iriri_pw}"

	class { 'postgresql::server': } # Install PostgreSQL
	
	postgresql::server::db { "${::app_db}_production":
  						user => $db_user,
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "${::app_db}_development":
  						user => "${db_user}_dev",
               password => postgresql_password($db_user, $db_pw),
  }

	postgresql::server::db { "${::app_db}_testing":
  						user => "${db_user}_test",
               password => postgresql_password($db_user, $db_pw),
  }
}
