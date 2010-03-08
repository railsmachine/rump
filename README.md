Rump 
====

Rump lets you run Puppet locally against a git checkout. 

This allows you to locally iterate your Puppet manifests very quickly, then 
push them up to a central repository somewhere else to share the changes. 

This also works well with a Capistrano-style deployment, where you remotely 
instruct Rump to check out a copy of the latest manifests and run them. 

Quirks
------

1. Puppet's fileserver (`source => "puppet:///..."` on File resources) doesn't 
   appear to work. For now, all files need to be templates. 

2. Manifests need to be modules so Puppet can pick them up correctly. 

Installing dependencies
-----------------------

On the server you're configuring with Puppet, run:

    $ sudo aptitude install puppet git-core

Make sure your hostname is set: 

    $ sudo vi /etc/hostname
      foo.bar.railsmachine.net
    $ sudo hostname -F /etc/hostname


Getting the repository
----------------------

On the target machine, make sure you have an SSH key for the machine where
your Puppet repo is kept. 

Now you can check out the repository: 

    $ rump clone git@github.com:railsmachine/puppet.git

You'll want to set up a `~/.gitconfig` in your home directory too: 

    [user]
    name = My Name
    email = me@railsmachine.com
    
    [push]
    default = matching


Running Puppet
--------------

When you make changes, run Puppet through Rump: 

    $ sudo ./rump

You can append options you'd normally pass to the `puppet` command at the end
of `rump`: 

    $ sudo ./rump --verbose --debug --noop


