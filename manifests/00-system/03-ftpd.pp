node default{
	# We're gonna need an FTP server, so ...
        class { 'vsftpd':
                anonymous_enable => 'NO',
                write_enable    => 'YES',
                chroot_local_user => 'YES',
                ftpd_banner     => "HI MAN WHATS UP",
                }
}
