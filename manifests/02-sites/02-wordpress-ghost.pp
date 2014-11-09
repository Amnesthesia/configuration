node default{
	class { "wordpress":
  	cache    => false,       # Static asset caching in NGINX (default: false)
  	user     => 'ghost', 
  	password => 'ghost', 
  	database => 'ghost', 
	}
}
