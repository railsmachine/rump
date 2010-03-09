Feature: Rump 
  To iterate quickly 
  When writing Puppet manifests
  A user 
  Should have a helper tool

  Scenario: Cloning a repository
    Given I am working in "/tmp"
    And I have an empty git repository named "master-puppet"
    And there is no "clone-puppet" repository
    When I run "rump clone master-puppet clone-puppet"
    Then I should have a git repository at "clone-puppet"

  Scenario: Doing a puppet run
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    And "puppet" is installed on my system
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When I run "rump go --confdir=/tmp/simple-puppet --vardir=/tmp/simple-puppet/var"
    Then I should see a file at "/tmp/checkout"

