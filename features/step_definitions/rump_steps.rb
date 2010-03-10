Given /^I am working in "([^\"]*)"$/ do |directory|
  @basedir = Pathname.new(directory)
end

Given /^I have an empty git repository named "([^\"]*)"$/ do |repo_name|
  repo_path = @basedir.join(repo_name)
  FileUtils.rm_rf(repo_path)
  FileUtils.mkdir_p(repo_path)
  
  Dir.chdir(repo_path) do 
    commands = ["git init -q", "touch foo", "git add foo", "git commit -qm 'init' ."]
    commands.each do |command|
      system(command).should be_true
    end
  end

  File.exists?(repo_path.join('.git')).should be_true
end

When /^I run "([^\"]*)"$/ do |cmd|
  if cmd.split(' ').first == "rump"
    command = %w(ruby -rubygems)
    command << ROOT.join('bin', 'rump')
    command << cmd.split[1..-1].join(' ')
    command = command.join(' ')
  else
    command = cmd
  end

  Dir.chdir(@basedir) do 
    system(command).should be_true
  end
end

Then /^I should have a git repository at "([^\"]*)"$/ do |repo_name|
  repo_path = @basedir.join(repo_name)
  File.exists?(repo_path.join('.git')).should be_true
end

Given /^there is no "([^\"]*)" repository$/ do |repo_name|
  repo_path = @basedir.join(repo_name)
  FileUtils.rm_rf(repo_path)
end

Given /^I have a simple Puppet repository named "([^\"]*)"$/ do |repo_name|
  repo_path = @basedir.join(repo_name)
  simple_path = ROOT.join('features', 'source', 'simple')
  hostname = Socket.gethostname

  FileUtils.rm_rf(repo_path)
  FileUtils.cp_r(simple_path, repo_path)

  File.open(repo_path.join('manifests', 'nodes', "#{hostname}.pp"), 'w') do |f|
    f << "node #{hostname} { include 'test' }"
  end
  
  Dir.chdir(repo_path) do 
    commands = ["git init -q", "git add .", "git commit -qm 'init' ."]
    commands.each do |command|
      system(command).should be_true
    end
  end

  File.exists?(repo_path.join('.git')).should be_true
end

Then /^I should see a file at "([^\"]*)"$/ do |path|
  File.exists?(path).should be_true
end

Given /^there is no "([^\"]*)" file$/ do |file|
  FileUtils.rm_rf(file).should be_true
end

Given /^"([^\"]*)" is on my path$/ do |command|
  system("which #{command}").should be_true
end
