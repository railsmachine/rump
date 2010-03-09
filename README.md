Rump 
====

Rump lets you run Puppet locally against a git checkout. 

This allows you to locally iterate your Puppet manifests very quickly, then 
push them up to a central repository somewhere else to share the changes. 

This also works well with a Capistrano-style deployment, where you remotely 
instruct Rump to check out a copy of the latest manifests and run them. 

Installing dependencies
-----------------------

On the server you're configuring with Puppet, run:

    $ sudo aptitude install puppet git-core

Make sure your hostname is set: 

    $ sudo vi /etc/hostname
      foo.bar.railsmachine.net
    $ sudo hostname -F /etc/hostname


Using Rump
----------

Check out your repository of Puppet manifests: 

    $ rump clone git@github.com:railsmachine/puppet.git

You'll want to set up a `~/.gitconfig` in your home directory so you know who's
making changes: 

    [user]
    name = My Name
    email = me@railsmachine.com
    
    [push]
    default = matching

There's nothing stopping you from running Rump against different checkouts/branches
of manifests. This is especially powerful when developing locally with the following
workflow: 

   1. `rump clone git@github.com:railsmachine/puppet.git`
   2. `rump go`
   3. `cd puppet && git checkout -b new_feature`
   4. make your changes && `rump go`
   5. iterate until everything's working
   6. `git checkout master && git merge new_feature`
   7. `git push`


Running Puppet
--------------

When you make changes, run Puppet through Rump: 

    $ sudo ./rump go

(I would love to use `run` instead of `go`, but `run` is a reserved word in Thor)

You can append options you'd normally pass to the `puppet` command at the end
of `rump go`: 

    $ sudo ./rump go --verbose --debug --noop


Testing Rump 
------------

There's a suite of Cucumber tests to fully exercise Rump in `features/`: 

    $ cucumber features/


Quirks
------

1. Puppet's fileserver (`source => "puppet:///..."` on File resources) doesn't 
   appear to work. For now, all files need to be templates. 

2. Manifests need to be modules so Puppet can pick them up correctly. 

