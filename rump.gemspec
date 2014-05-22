# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rump/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "rump"
  s.version     = Rump::VERSION
  s.authors     = ["Lindsay Holmwood"]
  s.email       = ["ops@railsmachine.com"]
  s.homepage    = "http://github.com/railsmachine/rump"
  s.summary     = %q{Rump helps you run Puppet locally against a Git checkout.}
  s.description = %q{Rump helps you run Puppet locally against a Git checkout. This is great for locally iterating your Puppet manifests very quickly, then pushng them up to a repository somewhere else to share the changes.}

  s.rubyforge_project = "rump"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'thor', '0.13.4'
  s.add_dependency 'bundler'

  s.add_development_dependency 'puppet'
  s.add_development_dependency 'cucumber'
end
