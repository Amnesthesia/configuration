node default{
	$web_root = "/var/www"
	$app_name = "iriri"
	
	class { "nginx": }				# Nginx as web server...
	class { "puma": } 				# ... with Puma serving up some..
	class { "capistrano": }		# ..capistrano-spiced...
  class { "rails": }				# ...rails!

	file { "database.yml":
        path    => "${web_root}/${app_name}/current/config/database.yml",
        owner   => $puma::puma_user,
        group   => $puma::web_user,
        mode    => '0644',
        content => template("database.yml.erb"),
  }~>
	file { "secrets.yml":
        path    => "${web_root}/${app_name}/current/config/secrets.yml",
        owner   => $puma::puma_user,
        group   => $puma::web_user,
        mode    => '0644',
        content => template("secrets.yml.erb"),
  }

	
	
	
		##
	### ${app_name} source code should be set up, so let's spawn up the server!
	##
        rails::app { 'iriri' :
                ruby_version => "ruby-2.1.0",
                #fqdn   =>      'iriri.amnesthesia.com',
                db      =>      "postgresql",
                server_name => ['${app_name}.amnesthesia.com','${app_name}.xyz', "${environment}.iriri.xyz"],
                shared_dirs => ['log','pids','assets','uploads'],
                uses    => { rmagick => true, imagemagick => true},
                deploy_using => "capistrano",
                serve_using => "nginx/puma",
        }
}
