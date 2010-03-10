#!/usr/bin/env ruby 

require 'thor'
require 'pathname'

# Thor's default stack trace on errors is ugly - make it pretty.
class Thor
  class << self
    def handle_argument_error(task, error)
      puts "#{task.name.inspect} was called incorrectly. Call as #{task.formatted_usage(self, banner_base == "thor").inspect}."
      exit 1
    end
  end
end


class Rump < Thor

  def initialize
    super
    @root = Pathname.new(Dir.getwd)
  end
    
  desc "clone repository [directory]", "clone a Git repository of Puppet manifests"
  def clone(repository, directory=nil)
    command = "git clone -q #{repository} #{directory}"
    system(command)
  end

  desc "go [puppet arguments]", "do a local Puppet run"
  def go(*puppet_args)
    if ENV['USER'] != "root"
      puts "You should probably be root when running this! Proceeding anyway..." 
    end
    
    args = []
    if has_frozen_components?
      args << "ruby" 
      args << "-I #{@root.join('vendor', 'facter', 'lib')}" 
      args << "-I #{@root.join('vendor', 'puppet', 'lib')}"
      args << "#{@root.join('vendor', 'puppet', 'bin', 'puppet')}"
    else
      unless system("which puppet > /dev/null")
        puts "You don't have Puppet installed!"
        puts "Please either install it on your system or freeze it with 'rump freeze'"
        exit 2
      end
      args << "puppet"
    end
    args << "--modulepath #{@root.join('modules')}"
    args << "--confdir #{@root.join('etc')}" unless puppet_args.include?("--confdir")
    args << "--vardir #{@root.join('var')}" unless puppet_args.include?("--vardir")
    args << "#{@root.join('manifests', 'site.pp')}"

    args += puppet_args

    command = args.join(' ')
    puts command if args.include?("--debug")
    system(command) ? exit(0) : exit(1)
  end

  desc "freeze repository project", "freeze Puppet into your manifests repository"
  def freeze(project, repository)
    command = "git submodule add #{repository} #{@root.join('vendor', project)}"
    system(command) ? exit(0) : exit(1)
  end

  private 
  def has_frozen_components?
    vendored = Dir.glob("#{@root.join('vendor')}/*").map {|v| v.split('/').last}
    vendored.include?("puppet") && vendored.include?("facter")
  end


end

