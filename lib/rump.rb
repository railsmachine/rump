#!/usr/bin/env ruby

require 'thor'
require 'pathname'

module Logging
  ESCAPES = { :green  => "\033[0;32m",
              :yellow => "\033[0;33m",
              :red    => "\033[47;31m",
              :reset  => "\033[0m" }

  def info(message)
    emit(:message => message, :color => :green)
  end

  def warn(message)
    emit(:message => message, :color => :yellow)
  end

  def error(message)
    emit(:message => message, :color => :red)
  end

  def emit(opts={})
    color   = opts[:color]
    message = opts[:message]
    print ESCAPES[color]
    print message
    print ESCAPES[:reset]
    print "\n"
  end
end

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
  include Logging

  def initialize
    super
    @root = Pathname.new(Dir.getwd)
    @install_root = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__))))
  end

  desc "clone <repository> [directory]", "clone a Git repository of Puppet manifests"
  def clone(repository, directory=nil)
    abort_unless_git_installed
    directory ||= File.basename(repository.split('/').last, '.git')
    command = "git clone -q #{repository} #{directory}"
    system(command)

    # A cloned repo may have submodules - automatically initialise them.
    if File.exists?(File.join(directory, '.gitmodules'))
      Dir.chdir(directory) do
        system("git submodule init")
        system("git submodule update")
      end
    end
  end

  desc "go [puppet arguments]", "do a local Puppet run"
  def go(*puppet_args)
    if ENV['USER'] != "root"
      warn "You should probably be root when running this! Proceeding anyway..."
    end

    args = []
    if has_frozen_components?
      args << "ruby"
      Dir.glob("#{@root.join('vendor')}/*").each do |dir|
        args << "-I #{@root.join('vendor', dir, 'lib')}"
      end
      args << "#{@root.join('vendor', 'puppet', 'bin', 'puppet')}"
      info "Using frozen Puppet from #{@root.join('vendor', 'puppet')}."
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
    system(command) ? exit(0) : exit(2)
  end

  desc "freeze [repository, project]", "freeze Puppet into your manifests repository"
  def freeze(*args)
    abort_unless_git_installed

    commands = []
    if args.size >= 2
      project    = args[0]
      repository = args[1]
      commands << { :command => "git submodule add #{repository} #{@root.join('vendor', project)}" }
      if args.detect { |arg| arg =~ /^--release\=(.+)/ }
        version = $1
        commands << { :command => "git checkout -b #{version} #{version}", :directory => @root.join('vendor', project) }
      end
    else
      commands << { :command => "git submodule add git://github.com/puppetlabs/puppet.git #{@root.join('vendor', 'puppet')}" }
      commands << { :command => "git submodule add git://github.com/puppetlabs/facter.git #{@root.join('vendor', 'facter')}" }
    end

    commands.each do |attrs|
      dir = attrs[:directory] || @root
      Dir.chdir(dir) do
        exit(2) unless system(attrs[:command])
      end
    end

    info "Freezing complete."
    info "Make sure to run git add + git commit with the proper arguments to make the freeze permanent!"
  end

  desc "scaffold <project>", "generate scaffolding for a repository of Puppet manifests"
  def scaffold(project)
    [ @root + project,
      @root + project + 'manifests',
      @root + project + 'modules',
      @root + project + 'var/reports',
      @root + project + 'vendor' ].each do |directory|
      FileUtils.mkdir_p(directory)
    end

    File.open(@root.join(project, 'README.md'), 'w') do |f|
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

  desc "init <project>", "initialise a repo of scaffolded Puppet manifests"
  def init(project)
    scaffold(project)
    repo_path = @root.join(project)
    template_path = @install_root.join('generators', 'git')

    Dir.chdir(repo_path) do
      commands = [ "git init --quiet --template=#{template_path}",
                   "git add .",
                   "git commit --quiet -am 'Initial commit.'" ]
      commands.each do |command|
        system(command)
      end
    end

    info "Your new Rump project has been initialised in #{repo_path}"
  end

  desc "whoami [rfc2822-address]", "set the current commit author"
  def whoami(address=nil)
    # getter
    if address
      name  = address[/^(.+)\s+</, 1]
      email = address[/<(.+)>$/, 1]

      unless name && email
        abort("Supplied address isn't a valid rfc2822 email address")
      end

      system("git config user.name '#{name}'")
      system("git config user.email '#{email}'")
    # setter
    else
      name = `git config user.name`.strip
      email = `git config user.email`.strip

      if name.empty? || email.empty?
        warn "You don't have a name or email set."
      else
        puts "#{name} <#{email}>"
      end
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
            error "You don't have #{bin.capitalize} installed!"
            error opts[:message] || "Please install it on your system."
            exit 3
          end
        end
      end
    METHOD
  end

end

