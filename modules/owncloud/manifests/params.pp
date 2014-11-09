class owncloud::params {
	case $::osfamily {
		Debian: {
			$nginx_pkgn = 'nginx'
		}
		/*RedHat: {
			$ssh_package_name = 'openssh-server'
		}*/
		default: {
			fail("Module propuppet-ssh does not support osfamily: ${::osfamily}")
		}
	}

}