node default{
	class { 'postgresql::server': } # Install PostgreSQL
	postgresql::server::db { "test_production":
  						user => "test",
               password => postgresql_password("test", "test"),
  }

	postgresql::server::db { "test_development":
  						user => "test_development",
               password => postgresql_password("test", "test"),
  }

	postgresql::server::db { "test_testing":
  						user => "test_test",
               password => postgresql_password("test", "test"),
  }
}
