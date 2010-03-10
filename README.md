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

Freezing Puppet
---------------

If you are using git, you can freeze Puppet into your project as a submodule. This
gives you a whole bunch of advantages: 

 * You only need Ruby installed on your system to run Puppet
 * A checkout of your manifests also gives you Puppet
 * Bind your manifests to a particular version of Puppet 
 * Test your manifests against new versions of Puppet in a separate branch
 * Manage upgrades of Puppet outside your operating system's release cycle

You can freeze Puppet very easily: 

    $ rump freeze puppet git://github.com/reductivelabs/puppet.git
    $ rump freeze facter git://github.com/reductivelabs/facter.git

This will freeze Puppet + Facter under `vendor/`. Alternatively, you can point 
the freezer at any Git repository (local or remote). 

When you run `rump go`, it checks whether you have frozen Puppet + Facter, and
runs the frozen Puppet if available.

Testing Rump 
------------

There's a suite of Cucumber tests to fully exercise Rump in `features/`: 

    $ cucumber features/

The scenarios are tagged with `@offline` and `@online`, depending on whether 
the test requires internet connectivity. Run all but `@online` tests with: 

    $ cucumber --tags ~@online features/


Quirks
------

1. Puppet's fileserver (`source => "puppet:///..."` on File resources) doesn't 
   appear to work. For now, all files need to be templates. 

2. Manifests need to be modules so Puppet can pick them up correctly. 

