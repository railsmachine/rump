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
    Given I am working in "/tmp/safe-puppet"
    When I touch "/tmp/safe-puppet/random"
    When I run "git add ."
    When I run "GIT_AUTHOR_NAME='root' git commit -m 'created random' ."
    Then the command should fail


  @online
  Scenario: Freezing Puppet + Facter as submodules
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
  Scenario: Freezing a specific submodule
    Given I am working in "/tmp"
    And I have a simple Puppet repository named "foobar"
    And there is no "simple-puppet" repository
    And there is no "/tmp/checkout" file
    When I run "rump clone foobar simple-puppet"
    Given I am working in "/tmp/simple-puppet"
    When I run "rump freeze facter git://github.com/reductivelabs/facter.git"
    And I run "rump freeze puppet git://github.com/reductivelabs/puppet.git"
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
    And I should see a file at "/tmp/my-new-project/README"



