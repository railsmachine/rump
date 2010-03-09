Feature: Rump 
  To iterate quickly 
  When writing Puppet manifests
  A user 
  Should have a helper tool

  Scenario: Cloning a repository
    Given I am working in "/tmp"
    And I have an empty git repository named "master-puppet"
    When I run "rump clone master-puppet clone-puppet"
    Then I should have a git repository at "clone-puppet"
