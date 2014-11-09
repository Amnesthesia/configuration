node default{
				##
        ### Install GitLab after setting up the postgresql database
				##

				#postgresql::server::db { $dbGitlab:
        #       user => $userGitlab,
        #       password => postgresql_password($userGitlab, $pwGitlab),
        #}~>
        #class{'gitlab':
        #        git_email       => $gitEmail,
        #        git_comment     => "Amnesthesia Laboratories",
        #        gitlab_domain   => "labs.amnesthesia.com",
        #        gitlab_dbtype   => "pgsql",
        #        gitlab_dbname   => $dbGitlab,
        #        gitlab_dbuser   => $userGitlab,
        #        gitlab_dbpwd    => $pwGitlab,
        #        ldap_enabled    => false,
        #}

}
