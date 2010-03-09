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
    
    unless system("which puppet > /dev/null")
      puts "You don't have Puppet installed!"
      exit 2
    end
    
    root = Pathname.new(Dir.getwd)
    
    args = %w(puppet)
    args << "--modulepath #{root.join('modules')}"
    args << "#{root.join('manifests', 'site.pp')}"
    args += puppet_args

    command = args.join(' ')
    puts command if args.include?("--debug")
    system(command)
  end

end

