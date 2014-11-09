node default {
	##
	### Set up some usernames & passwords
	##
        $userAmnesthesia = 'incarnation'
        $pwAmnesthesia = 'ch4ng3!n0w!'

        $pwamnsths = 'ch4ng3!n0w!'
        $pwghost = 'ch4ng3!n0w!'

        $userIriri = 'achiever'
        $pwIriri = '1r1r1ng{BANANAPH0NE}'

        $userJustbear = 'teddy'
        $pwJustbear = 'ok!just(BEAR)'

        $domainGitlab = 'labs.amnesthesia.com'
        $userGitlab = 'amnsthslab'
        $pwGitlab = 'amn3sth3s14[Laboratories]'
        $dbGitlab = 'lab'

	##
	### Include and declare
	##

        include git	# Install Git
        include nodejs 	# Install nodeJS
				class {"ohmyzsh":}		# Lets declare ohmyzsh so we can install it once users are created
				apt::pin{ 'sid': priority => 100 }
		
				# Configure git        
        git::config { 'user.name':
                        value => 'amnesthesia',
        }

        git::config { 'user.email':
                        value => "sintpanda@gmail.com",
        }

				##
        ### Create Groups
				##
        group{"nobody":
                ensure => present,
        }
				##
        ### Create default $HOME directory structure
	##
        file{ ["/etc/skel", 
	       	"/etc/skel/public_html", 
		"/etc/skel/logs", 
		"/etc/skel/public_html/initial", 
		"/etc/skel/public_html/initial/public", 
		"/etc/skel/public_html/initial/logs", 
		"/etc/skel/public_html/initial/private"]:
                ensure => "directory",
                group => "nobody",
                mode => 755,
        }~>

			
	


	
	##
	### and THEN create the users!
	##
	user{"amnesthesia":
                ensure => present,
                groups => "users",
                password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${pwamnsths} | tr -d '\n'"),
                managehome => true,
        }~>user{"ghost":
                ensure => present,
                groups => "www-data",
                password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${pwghost} | tr -d '\n'"),
                managehome => true,
        }~> 

	##
	### These users want vim!
	##
        class { "vim":
                user => "amnesthesia",
                home_dir => "/home/",
                }~>vim::plugin { 'solarized': source => 'https://github.com/altercation/vim-colors-solarized.git',}

	##
	### and oh-my-zsh
	##
        ohmyzsh::install { ['amnesthesia', 'root', 'ghost']: }
        ohmyzsh::plugins { ['amnesthesia', 'root', 'ghost']: plugins => 'colorize git github gem gitignore postgres mysql rails gnu-utils' }
        ohmyzsh::theme { ['amnesthesia', 'root', 'ghost']: theme => 'avit' }

}
