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
    @install_root = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__))))
  end
    
  desc "clone repository [directory]", "clone a Git repository of Puppet manifests"
  def clone(repository, directory=nil)
    abort_unless_git_installed
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
      Dir.glob("#{@root.join('vendor')}/*").each do |dir|
        args << "-I #{@root.join('vendor', dir, 'lib')}" 
      end
      args << "#{@root.join('vendor', 'puppet', 'bin', 'puppet')}"
      puts "Using frozen Puppet from #{@root.join('vendor', 'puppet')}."
    else
      abort_unless_puppet_installed(:message => "Please either install it on your system or freeze it with 'rump freeze'")
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

  desc "freeze [repository project]", "freeze Puppet into your manifests repository"
  def freeze(*args)
    abort_unless_git_installed

    commands = [] 
    if args.size == 2
      project    = args.first
      repository = args.last
      commands << "git submodule add #{repository} #{@root.join('vendor', project)}"
    else
      commands << "git submodule add git://github.com/reductivelabs/puppet.git #{@root.join('vendor', 'puppet')}"
      commands << "git submodule add git://github.com/reductivelabs/facter.git #{@root.join('vendor', 'facter')}"
    end

    commands.each do |command|
      exit(1) unless system(command)
    end
  end

  desc "scaffold project", "generate scaffolding for a repository of Puppet manifests"
  def scaffold(project)
    [ @root.join(project),
      @root.join(project, 'manifests'),
      @root.join(project, 'modules'),
      @root.join(project, 'vendor') ].each do |directory|
      FileUtils.mkdir_p(directory)
    end

    File.open(@root.join(project, 'README'), 'w') do |f|
      f << <<-README.gsub(/^ {8}/, '')
        #{project} manifests
        #{"=" * project.size}==========

        modules/ <= Puppet modules
        manifests/ <= Puppet nodes 
        vendor/ <= frozen Puppet + Facter

        Running Puppet with Rump
        ------------------------

        From within this directory, run: 

            rump go

        You can pass options to Puppet after the 'go': 

            rump go --debug --test 

        Freezing Puppet
        ---------------

        Firstly, you need to create a git repository: 

            git init 

        Now you can freeze Puppet: 

            rump freeze 

        Once Rump has frozen Puppet, commit the changes: 

            git commit -m 'added facter + puppet submodules' .

        Now Rump will use the frozen Puppet when you run 'rump go'.

      README
    end
  end

  desc "init project", "generate scaffolding for a repository of Puppet manifests"
  def init(project)
    scaffold(project)
    repo_path = @root.join(project)
    template_path = @install_root.join('generators', 'git')
   
    Dir.chdir(repo_path) do 
      command = "git init --template=#{template_path}"
      system(command)
    end
  end

  private 
  def has_frozen_components?
    vendored = Dir.glob("#{@root.join('vendor')}/*").map {|v| v.split('/').last}
    vendored.include?("puppet") && vendored.include?("facter")
  end

  # helper + abortive methods 
  %w(puppet git).each do |bin|
    class_eval <<-METHOD, __FILE__, __LINE__
      no_tasks do 
        def #{bin}_installed?
          `which #{bin}` =~ /#{bin}$/ ? true : false
        end
  
        def abort_unless_#{bin}_installed(opts={})
          unless #{bin}_installed?
            puts "You don't have #{bin.capitalize} installed!"
            puts opts[:message] || "Please install it on your system."
            exit 2
          end
        end
      end
    METHOD
  end

end

