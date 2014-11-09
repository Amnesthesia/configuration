node default{
	class { "wordpress":
  	cache    => false,       # Static asset caching in NGINX (default: false)
  	user     => 'test', 
  	password => 'test', 
  	database => 'test', 
	}
}
