Feature: Rump
  To iterate quickly
  When writing and running
  Puppet manifests
  A user
  Should have a helper tool
  To smooth things out

  @offline
  Scenario: Cloning a repository
    Given I am working in "/tmp"
    And I have an empty git repository named "master-puppet"
    And there is no "clone-puppet" repository
    When I run "rump clone master-puppet clone-puppet"
    Then I should have a git repository at "clone-puppet"

  @offline
  Scenario: Doing a puppet run
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    And "puppet" is on my path
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When I run "rump go"
    Then I should see a file at "/tmp/checkout"

  @offline
  Scenario: Initialising a safe repo
    Given I am working in "/tmp"
    And there is no "safe-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init safe-puppet"
    Then I should have a git repository at "safe-puppet"

  @offline
  Scenario: Verifying author name
    Given I am working in "/tmp"
    And there is no "safe-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init safe-puppet"
    Then I should have a git repository at "safe-puppet"
    Given I am working in "/tmp/safe-puppet"
    When I touch "/tmp/safe-puppet/random"
    When I run "git add ."
    Then running "GIT_AUTHOR_NAME=root git commit -m 'created random' ." should fail

  @offline
  Scenario: Verifying author email
    Given I am working in "/tmp"
    And there is no "safe-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init safe-puppet"
    Then I should have a git repository at "safe-puppet"
    Given I am working in "/tmp/safe-puppet"
    When I touch "/tmp/safe-puppet/random"
    When I run "git add ."
    Then running "GIT_AUTHOR_EMAIL=me@$(hostname) git commit -m 'created random' ." should fail

  @offline
  Scenario: Setting author email
    Given I am working in "/tmp"
    And there is no "whoami-email-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init whoami-email-puppet"
    Then I should have a git repository at "whoami-email-puppet"
    Given I am working in "/tmp/whoami-email-puppet"
    When I run "rump whoami 'Spoons McDoom <spoons@mcdoom.com>'"
    When I touch "/tmp/whoami-email-puppet/random"
    When I run "git add ."
    Then running "GIT_AUTHOR_EMAIL=$(git config user.email) git commit -m 'created random' ." should succeed

  @offline
  Scenario: Setting author name
    Given I am working in "/tmp"
    And there is no "whoami-name-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init whoami-name-puppet"
    Then I should have a git repository at "whoami-name-puppet"
    Given I am working in "/tmp/whoami-name-puppet"
    When I run "rump whoami 'Spoons McDoom <spoons@mcdoom.com>'"
    When I touch "/tmp/whoami-name-puppet/random"
    When I run "git add ."
    Then running "GIT_AUTHOR_NAME=$(git config user.name) git commit -m 'created random' ." should succeed

  @offline
  Scenario: Getting author name and email
    Given I am working in "/tmp"
    And there is no "whoami-getter-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump init whoami-getter-puppet"
    Then I should have a git repository at "whoami-getter-puppet"
    Given I am working in "/tmp/whoami-getter-puppet"
    When I run "rump whoami 'Spoons McDoom <spoons@mcdoom.com>'"
    Then running "rump whoami" should output "Spoons McDoom <spoons@mcdoom.com>"

  @online
  Scenario: Freezing Puppet + Facter as gems
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When I run "rump freeze"
    And I run "rump go"
    Then I should see a file at "/tmp/checkout"

  @online
  Scenario: Freezing Puppet + Facter as git repos
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When the Gemfile looks like this:
      """
      source :rubygems

      gem "rump"
      gem "puppet", "0.0", :git => "git://github.com/puppetlabs/puppet.git"
      gem "facter", "0.0", :git => "git://github.com/puppetlabs/facter.git"
      """
    When I run "rump freeze"
    And I run "rump go"
    Then I should see a file at "/tmp/checkout"

  @online
  Scenario: Freezing Puppet + Facter as git repos with specific versions
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When the Gemfile looks like this:
      """
      source :rubygems

      gem "rump"
      gem "puppet", "2.7.0rc1", :git => "git://github.com/puppetlabs/puppet.git", :tag => "2.7.0rc1"
      gem "facter", "1.5.9rc5", :git => "git://github.com/puppetlabs/facter.git", :tag => "1.5.9rc5"
      """
    When I run "rump freeze"
    And I run "rump go"
    Then I should see a file at "/tmp/checkout"

  @online
  Scenario: Freezing and running Puppet 2.6
    Given I am working in "/tmp"
    And I have a simple Puppet 2.6 repository named "foobar"
    And there is no "tagged-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump clone foobar tagged-puppet"
    Given I am working in "/tmp/tagged-puppet"
    When the Gemfile looks like this:
      """
      source :rubygems

      gem "rump"
      gem "puppet", "2.6.7", :git => "git://github.com/puppetlabs/puppet.git", :tag => "2.6.7"
      gem "facter", "1.5.8", :git => "git://github.com/puppetlabs/facter.git", :tag => "1.5.8"
      """
    When I run "rump freeze"
    And I run "rump go"
    Then I should see a file at "/tmp/checkout"

  @offline
  Scenario: Generating project scaffolding
    Given I am working in "/tmp/"
    When I run "rump scaffold my-new-project"
    Given I am working in "/tmp/my-new-project"
    Then I should see the following directories:
      | directory                     |
      | /tmp/my-new-project           |
      | /tmp/my-new-project/manifests |
      | /tmp/my-new-project/modules   |
      | /tmp/my-new-project/vendor    |
    And I should see a file at "/tmp/my-new-project/README.md"



