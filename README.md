Rump
====

Rump helps you run Puppet locally against a Git checkout.

Rump encourages a Puppet workflow where you quickly + iteratively develop your
Puppet manifests on a single machine, then push your changes up to a repository
to deploy to the rest of your infrastructure.

This workflow also complements a Capistrano or MCollective-style deployment,
where you remotely instruct Rump to check out a copy of the latest manifests
and run them.

Rump also has the ability to freeze Puppet in to the manifests repository,
letting you quickly test different versions of Puppet without waiting for
packages to appear, and reducing the dependencies on a system to run Puppet
down to just Ruby and git.

Installing
----------

    $ gem install rump

Using Rump
----------

Make sure you check out the [man pages](rump/blob/master/man/rump.1.ronn).

Check out your repository of Puppet manifests:

    $ rump clone git@github.com:me_at_example_dot_org/puppet.git

You'll want to set up a `~/.gitconfig` in your home directory so you know who's
making changes:

    [user]
    name = My Name
    email = me@example.org

    [push]
    default = matching

When you make changes, run Puppet through Rump:

    $ sudo rump shake

You can append options you'd normally pass to the `puppet` command at the end
of `rump shake`:

    $ sudo rump shake --verbose --debug --noop

There's nothing stopping you from running Rump against different checkouts/branches
of manifests. This is especially powerful when developing locally with the following
workflow:

   1. `rump clone git@github.com:me_at_example_dot_org/puppet.git`
   2. `rump shake`
   3. `cd puppet && git checkout -b new_feature`
   4. Make your changes &amp;&amp; `rump shake --noop` to see what will change.
   5. Apply the changes with `rump shake`
   6. *Iterate until everything's working*
   7. `git checkout master && git merge new_feature`
   8. `git push`

Freezing Puppet
---------------

If you are using Git, you can freeze Puppet into your project as a submodule. This
gives you a whole bunch of advantages:

 * You only need Ruby installed on your system to run Puppet
 * A checkout of your manifests also gives you Puppet
 * Bind your manifests to a particular version of Puppet
 * Test your manifests against new versions of Puppet in a separate branch
 * Manage upgrades of Puppet outside your operating system's release cycle

You can freeze Puppet very easily:

    $ rump freeze

This will freeze Puppet + Facter under `vendor/`. Alternatively, you can point
the freezer at any Git repository (local or remote).

When you run `rump shake`, it checks whether you have frozen Puppet + Facter, and
runs the frozen Puppet if available.

You can also freeze in arbitrary Git repos:

    $ rump freeze moonshine git://github.com/railsmachine/moonshine.git

These will automatically be added to the load path when you run `rump shake`

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
   behave as expected on Puppet < 2.6. If you are using Puppet < 2.6, all files
   need to be templates.

2. Manifests need to be in modules so Puppet can pick them up correctly.

License
-------

Copyright Rails Machine LLC 2010-2011, released under the LGPL. See
[LICENSE](rump/blob/master/LICENSE) for more info.
