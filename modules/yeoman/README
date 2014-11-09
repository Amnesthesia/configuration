puppet-yeoman
=============

This is the yeoeman puppet module, which makes it easier to install yeoman, it's dependencies, and any existing yeoman projects.

For a working example checkout https://github.com/frankcarey/angular-vm

To Just install yeoman and it's dependencies:
---------------------------------------------

    include yeoman

To install specific yeoman generators (and install yeoman)
------------------------------------

    yeoman::generator { 'generator-angular': }

To load an existing project that uses yeoman, grunt, and bower (and instal yeoman)
------------------------------------------------------------------

   yeoman::project { 'myProject':
       path => "/git/checkout/path", #required
       repo => "https://github.com/user/project.git", #required
       generators => ["generator-angular"], #optional
       npm_install => true #default
       bower_install => true #default
       grunt_build => true #default
       grunt_serve => false #default
   }

This example will:
* Install yeoman and any generators you specify
* Clone your git repo to path (uses vcsrepo)
* Run npm install
* Run bower install
* Run grunt build --force (Note that any errors will still fail)
* Run grunt serve

This module could certainly be improved. Issues and pull requests welcome.
Please log tickets and issues on github: [https://github.com/frankcarey/puppet-yeoman]

License
-------

MIT
