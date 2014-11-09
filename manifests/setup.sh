#!/bin/bash


##
### Clear the screen
##
function clear_screen(){
	echo -e '\0033\0143'
}


##
### Display menu for User management
##
function userMenu(){
	clear_screen
	echo "======================================"
	echo "- OS Set-up and Configuration: Users -"
	echo "======================================"
	echo "What do you want to do?"
	options=("New user", "Remove user", "New user Wordpress site", "New user Rails app", "Back")

	select opt in "${options[@]}"
	do
		case $opt in
			"New user,")
				createUser	# Create a new user
				;;
			"New user Wordpress site,")
				newUserWordpress	# Create a new wordpress site and symlink to users home
				;;
			"New user Rails app,")
				newUserRails			# Create a new Rails app and symlink to users home
				;;
			"Remove user,")
				removeUser				# Remove a user (and its manifest)
				;;
			"Back")
				initMenu					# Return to main menu
				;;
		esac
	done
	
}

function webMenu(){
	clear_screen
	echo "======================================"
	echo "- OS Set-up and Configuration: Web   -"
	echo "======================================"
	echo "What do you want to do?"
	options=("New system-wide Rails app", "New system-wide Wordpress site", "New user Wordpress site", "New user Rails app", "Back")

	select opt in "${options[@]}"
	do
		case $opt in
			"New system-wide Rails app,")
				newRailsApp										# Sets up a fresh Rails app in specified web-root 
				;;
			"New system-wide Wordpress site,")
				newWordpress									# Sets up a new wordpress site in specified web-root
				;;
			"New user Wordpress site,")
				read -p "Username: " -e username
				export FACTER_new_site_owner="$username"
				newUserWordpress							# Sets up a new wordpress site in specified web-root and symlink it to a given user
				;;
			"New user Rails app,")
				export FACTER_new_site_owner="$username"
				newUserRails									# Sets up a new Rails app in specified web-root and symlink it to a given user
				;;
			"Back")
				clear_screen
				initMenu	# Back to main menu
				;;
		esac
	done
}

function initMenu(){
	echo "==============================="
	echo "- OS Set-up and Configuration -"
	echo "==============================="
	echo "What do you want to do?"
	options=("Initial set-up", "Configure users", "Configure sites & web", "Reset DBs", "Reset Sites", "Reset ftp, users, groups", "Quit")

	select opt in "${options[@]}"
	do
		case $opt in
			"Initial set-up,")
				initSystem			# Set up everything with a manifest
				initDBs					# including databases
				initSites				# and sites
				;;
			"Configure users,")
				userMenu				# Display user management menu
				;;
			"Configure sites & web,")
				webMenu					# Display web management menu
				;;
			"Reset DBs,")
				initDBs					# Set up configured databases anew
				;;
			"Reset Sites,")
				initSites				# Set up configured sites anew
				;;
			"Reset ftp, users, groups,")
				initSystem			# Set up system stuff like groups, users (and vsftpd)
				;;
			"Quit")
				break
				;;
			*) echo "Invalid option: $opt"
		esac
		clear_screen
		initMenu
	done
}

##
### Request all variables required to set up a Rails app
##
function requestRailsVariables(){
	echo -e "\e[96mTime to spawn a rails app? Some information will be required..."
	read -p "Web-root [/var/www]: " -i "/var/www" -e web_root
	read -p "App name: " -e app_name
	read -p "Domain: " -i "${app_name}.amnesthesia.com" -e app_domain
	read -p "PostgreSQL database: " -e app_db
	read -p "PostgreSQL username: " -e app_user
	read -p "PostgreSQL password: " -e app_pw
	read -p "GitHub repository: " -e app_git

	export FACTER_new_site_web_root="$web_root"
	export FACTER_new_site_domain="$domain"
	export FACTER_new_site_app_name="$app_name"
	export FACTER_new_site_app_db="$app_db"
	export FACTER_new_site_app_user="$app_user"
	export FACTER_new_site_app_pw="$app_pw"
	if [ -z "$app_git"]; then
		export FACTER_new_site_app_git="$app_git"
	else
		export FACTER_new_site_app_git="$app_git"
	fi
	
}

##
### Request all variables required to set up a Wordpress site
##
function requestWordpressVariables(){
	echo "Time to spawn a wordpress app? Some information will be required..."
	read -p "Web-root [/var/www]: " -i "/var/www" -e web_root
	read -p "App name: " -e app_name
	read -p "Domain: " -i "${app_name}.amnesthesia.com" -e app_domain
	read -p "MySQL database: " -e app_db
	read -p "MySQL username: " -e app_user
	read -p "MySQL password: " -e app_pw
	read -p "GitHub repository: " -e app_git

	export FACTER_new_site_domain="$app_domain"
	export FACTER_new_site_web_root="$web_root"
	export FACTER_new_site_app_name="$app_name"
	export FACTER_new_site_app_db="$app_db"
	export FACTER_new_site_app_user="$app_user"
	export FACTER_new_site_app_pw="$app_pw"
	if [ -z "$app_git"]; then
		export FACTER_new_site_app_git=""
	else
		export FACTER_new_site_app_git="$app_git"
	fi
}

##
### Set up configured databases from manifests
##
function initDBs(){
	echo -e "\e[1m\e[33m== \e[92mSetting up databases ..."

	## Set passwords (find files named 00-.. or 01-postgresql-[app]
	for filename in $(ls -rS 01-databases/ | grep 0 | sort); 
	do
		split_string=(${filename//-/ })
		if [[ "${split_string[1]}" == "postgresql" ]]; then
			dbnm=$(echo "${split_string[2]}" | tr -d '.pp')
			echo -e "\e[1m\e[33m== \e[92mDatabase ${dbnm} is going to need a password..."
			read -p "Enter password: " -e dbpw

			# Make database a temporary fact
			export FACTER_database_${dbnm}_pw="$dbpw"
		fi 
	done
	
	## Apply manifests
	for filename in $(ls -rS 01-databases/ | grep 0 | sort); 
	do
		puppet apply 01-databases/$filename; 
	done
}

##
### Set up configured sites (and prepare directories / download source code) from manifests
##
function initSites(){
	echo -e "\e[1m\e[33m== \e[92mFetching site sources and configuring web server ..."
	for filename in $(ls -rS 02-sites/ | grep 0 | sort); 
	do 
		puppet apply 02-sites/$filename; 
	done

	#puppet apply 01-databases/01-omd.pp
}

##
### Set up system stuff like FTP, Users, Groups, SSH, OMD, etc
##
function initSystem(){
	echo -e "\e[1m\e[33m== \e[92mSetting up users, groups, SSH and FTP ..."

	## Set passwords (find files named 01-.. or 02-user-[username]
	for filename in $(ls -rS 00-system/ | grep 0 | sort); 
	do
		split_string=(${filename//-/ })
		if [[ "${split_string[1]}" == "user" ]]; then
			unm=$(echo "${split_string[2]}" | tr -d '.pp')
			echo -e "\e[1m\e[33m== \e[92mUser ${unm} is going to need a password..."
			read -p "Enter password: " -e userpass
			export FACTER_user_${unm}_pw="$userpass"
		fi
	done

	## Apply manifests
	for filename in $(ls -rS 00-system/ | grep 0 | sort); 
	do
		puppet apply 00-system/$filename;
	done
}

function init(){
	#
	## Identify type of computer (laptop, stationary, server?)
	## Then let user choose the type of set-up
	#
	if [[ "$(facter osfamily)" == "Arch" ]]; then
		echo -e "\e[91mNo configuration for your Arch system yet!"
	else
		initSystem
		initDBs
		initSites
	fi
	
}

##
### Set up a new Rails app symlinked into a user's directory
#
function newUserRailsApp(){
	clear_screen
	requestRailsVariables
	user=$(echo $FACTER_new_site_owner)		# Get previously exported variables
	git=$(echo $FACTER_new_site_app_git)
	pwd=$(pwd)
	app_name=$(echo $FACTER_new_site_app_name)
	
	# Check if a user was found in previously exported variables, otherwise
	# request username
	if [ -z "$user" ]; then
		read -p "* \e[91mNo user was specified. Enter username: " -e user
		export FACTER_new_site_owner="$user"
	else
		echo -e "\e[1m\e[33m== \e[92mSetting up new Rails 4.0 app for $user"
	fi
	
	# Set up database for Rails-app
	puppet apply "01-databases/00-postgresql-new.pp"
	puppet apply "01-databases/02-postgresql-${app_name}.pp"
	
	# If a git repo was provided, download source code
	if [[ ! -z $git ]]; then
		puppet apply "02-sites/00-user-site-source-new.pp"
	else
	# Otherwise create directory structure and check for Ruby or RVM
		mkdir -p /home/$user/public_html/$app_name/
		PKG_RUBY=$(dpkg-query -W --showformat='${Status}\n' ruby|grep "install ok installed")
		PKG_RVM=$(dpkg-query -W --showformat='${Status}\n' rvm|grep "install ok installed")

		if [[ "" == "$PKG_RVM" && "" == "$PKG_RUBY" ]]; then
			echo -e "\e[91m- Ruby is not installed, so installing Rails to create app"
			gem install rails
		else
			echo -e "\e[91m- Ruby or rvm is installed, so creating Rails app ..."
		fi

		# Create new Rails app 
		cd /home/$user/public_html/
		rails new $app_name
	fi

	puppet apply "02-sites/00-user-rails-server-new.pp"
	puppet apply "02-sites/02-rails-server-${app_name}.pp"

	ln -s /home/$user/public_html/$app_name $(echo $FACTER_web_root)/$app_name/current
} 

##
### Create new Rails app without linking it to any user
##
function newRailsApp(){
	clear_screen
	requestRailsVariables
	git=$(echo $FACTER_new_site_app_git)
	pwd=$(pwd)
	web_root=$(echo $FACTER_new_site_web_root)
	app_name=$(echo $FACTER_new_site_app_name)

	echo -e "\e[1m\e[33m== \e[92m Setting up new sitewide Rails app"

	puppet apply "01-databases/00-postgresql-new.pp"
	puppet apply "01-databases/02-postgresql-${app_name}.pp"
	
	if [[ ! -z $git ]]; then
		puppet apply "02-sites/00-site-source-new.pp"
	else
		if [[ "" == "$PKG_RVM" && "" == "$PKG_RUBY" ]]; then
			echo "\e[91m- Ruby is not installed? Attempting to install rails to create app"
			#gem install rails
		else
			echo "\e[91m- Ruby or rvm is installed, so creating Rails app ..."
		fi
		mkdir $web_root/$app_name/
		rails new $app_name $web_root/app_name/current
	fi
	

	puppet apply "02-sites/00-rails-server-new.pp"
	puppet apply "02-sites/02-rails-server-${app_name}.pp"

}

function newWordpress(){
	echo "\e[1m\e[33m== \e[92m Wordpress information"
	requestWordpressVariables
	
	echo "\e[1m\e[33m== \e[92m Setting up systemwide Wordpress app ..."


	app_name=$(echo $FACTER_new_site_app_name)
	
	if [[ ! -z $git ]]; then
		puppet apply "02-sites/00-user-site-source-new.pp"
	fi
	
	puppet apply "02-sites/00-wordpress-new.pp"
	puppet apply "02-sites/02-wordpress-${app_name}.pp"

	## Generate template for 02-sites/02-user-site.pp with specified information here
	## 
	## FACTER_new_site_domain
	## FACTER_new_site_web_root
	## FACTER_new_site_owner
	## FACTER_new_site_name
	## FACTER_new_site_app_user
	## FACTER_new_site_app_db
	## FACTER_new_site_app_pw
	## FACTER_new_site_app_git
	##
}

function newUserWordpress(){
	echo "\e[1m\e[33m== \e[92mWordpress information"
	requestWordpressVariables

	user=$(echo $FACTER_new_site_owner)
	
	if [ -z "$user" ]; then
		read -p "No user was specified. Enter username: " -e user
		export FACTER_new_site_owner="$user"
	else
		echo "\e[1m\e[33m== \e[92mSetting up new Wordpress app for $user ..."
	fi

	app_name=$(echo $FACTER_new_site_app_name)

	puppet apply "01-databases/00-mariadb-new.pp"
	puppet apply "01-databases/02-mariadb-${app_name}.pp"
	
	if [[ ! -z $git ]]; then
		puppet apply "02-sites/00-user-site-source-new.pp"
	fi
	
	puppet apply "02-sites/00-wordpress-new.pp"
	puppet apply "02-sites/02-wordpress-${app_name}.pp"

	ln -s $(echo $FACTER_web_root)/$app_name/current /home/$user/public_html/$app_name
}


##
### Create a new user (and optionally link a new Wordpress or Rails-app to it)
##
function createUser(){
	echo "\e[1m\e[33m== \e[92mUser information"
	read -p "Username: " -e username
	read -p "Password: " -e password
	export FACTER_new_user_username="$username"
	export FACTER_new_user_pw="$password"
	echo "\e[1m\e[33m== \e[92mCreating user ..."
	puppet apply 00-system/00-user-new.pp
	puppet apply "00-system/02-user-${username}.pp"
	read -p "Would you also like to set up Wordpress or Rails for this user? [W/R/n]" -e answer
	
	while [[ ! "$answer" =~ ^[wWrRnN]$ ]]; do
		read -p "Would you also like to set up Wordpress or Rails for this user? [W/R/n]" -e answer
	done
	export FACTER_new_site_owner="$username"

	case $answer in
		"W")
			newUserWordpress
			;;
		"w")
			newUserWordpress
			;;
		"R")
			newUserRailsApp
			;;
		"r")
			newUserRailsApp
			;;
		"n")
			break
			;;
	esac
}


initMenu



##
## Todo: 
## 	
## Git repos for kommeralltiditid / etc
## Wordpress config template
## Docker
## Ensure services are running
##


#puppet apply 02-sites/02-wordpress-kommeralltiditid.pp
#puppet apply 02-sites/02-wordpress-amnesthesia.pp

#puppet apply 03-scripts/00-ruby-rheya.pp # Yet to be written

#puppet apply 04-jenkins/00-jenkins.pp
#puppet apply 04-maintenance/01-open-monitoring-distribution.pp
