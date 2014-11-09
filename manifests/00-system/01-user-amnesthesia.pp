node default{
	class {"ohmyzsh":}		# Lets declare ohmyzsh so we can install it once users are created
	apt::pin{ 'sid': priority => 100 }
		
	$pw = "${::user_amnesthesia_pw}"
	##
	### and THEN create the users!
	##
	user{"amnesthesia":
                ensure => present,
                groups => "users",
                password => generate('/bin/sh', '-c', "mkpasswd -m sha-512 ${::user_amnesthesia_pw} | tr -d '\n'"),
                managehome => true,
        }
	class { "vim":
                user => "amnesthesia",
                home_dir => "/home/amnesthesia",
                }~>vim::plugin { 'solarized': source => 'https://github.com/altercation/vim-colors-solarized.git',}

	##
	### and oh-my-zsh
	##
        ohmyzsh::install { 'amnesthesia': }
        ohmyzsh::plugins { 'amnesthesia': plugins => 'colorize git github gem gitignore postgres mysql rails gnu-utils' }
        ohmyzsh::theme { 'amnesthesia': theme => 'avit' }
}
