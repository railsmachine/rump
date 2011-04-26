Rump
====

Rump helps you run Puppet locally against a Git checkout.

Rump supports a Puppet workflow where you quickly + iteratively develop your
Puppet manifests on a single machine, then push your changes up to a repository
to deploy to the rest of your infrastructure.

This workflow also complements a Capistrano or MCollective-style deployment,
where you remotely instruct Rump to check out a copy of the latest manifests
and run them.

Rump also has the ability to freeze Puppet in to the manifests repository,
letting you quickly test different versions of Puppet without waiting for
packages to appear, and reducing the dependencies on a system to run Puppet
down to just Ruby and git.

Installing dependencies
-----------------------

On the server you're configuring with Puppet, run:

    $ sudo aptitude install puppet git-core

Make sure your hostname is set:

    $ sudo vi /etc/hostname
      foo.bar.example.org
    $ sudo hostname -F /etc/hostname


Using Rump
----------

Make sure you check out the [man pages](blob/master/man/rump.1.ronn).

Check out your repository of Puppet manifests:

    $ rump clone git@github.com:me_at_example_dot_org/puppet.git

Now `cd` into the directory, and do a Puppet run:

    $ sudo rump go

There's nothing stopping you from running Rump against different checkouts/branches
of manifests. This is especially powerful when developing locally with the following
workflow:

   1. `rump clone git@github.com:me_at_example_dot_org/puppet.git`
   2. `rump go`
   3. `cd puppet && git checkout -b new_feature`
   4. Make your changes &amp;&amp; `rump go`
   5. *Iterate until everything's working*
   6. `git checkout master && git merge new_feature`
   7. `git push`


Running Puppet
--------------

When you make changes, run Puppet through Rump:

    $ sudo rump go

You can append options you'd normally pass to the `puppet` command at the end
of `rump go`:

    $ sudo rump go --verbose --debug --noop

Freezing Puppet
---------------

Alternatively, if you want to live on the bleeding edge and eschew your
distribution's packages, you can run Rump entirely from RubyGems or Git. This
gives you a whole bunch of advantages:

 * You only need Ruby installed on your system to run Puppet
 * A checkout of your manifests also gives you Puppet
 * Bind your manifests to a particular version of Puppet
 * Test your manifests against new versions of Puppet in a separate branch
 * Manage upgrades of Puppet outside your operating system's release cycle

You can freeze Puppet and it's dependencies very easily:

    $ rump freeze

This will freeze Puppet + Facter under `vendor/`, using Bundler.

When you run `rump go`, Rump checks whether you have frozen Puppet + Facter, and
runs the frozen Puppet if available.

You can manage the versions of Puppet you want frozen using the `Gemfile` at
the root of your project. To use a specific version of Puppet, edit your
`Gemfile`:

    ``` ruby
    source :rubygems

    gem "puppet", "2.6.4"
    ```

If you want to live on the bleeding edge, you can run Puppet out of git:

    ``` ruby
    source :rubygems

    gem "puppet", "2.6.7", :git => "git://github.com/puppetlabs/puppet.git", :tag => "2.7.0rc1"
    gem "facter", "1.5.8", :git => "git://github.com/puppetlabs/facter.git", :tag => "1.5.9rc5"
    ```

Any dependency you bundle will automatically be added to the load path when you
run `rump go`.

Developing + Testing Rump
-------------------------

Check out the repository, and run `bundle install` to suck down all the
required development dependencies.

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

