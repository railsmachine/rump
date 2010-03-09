Given /^I am working in "([^\"]*)"$/ do |directory|
  @basedir = Pathname.new(directory)
end

Given /^I have an empty git repository named "([^\"]*)"$/ do |reponame|
  repopath = @basedir.join(reponame)
  FileUtils.rm_rf(repopath)
  FileUtils.mkdir_p(repopath)
  command = "cd #{repopath} && git init -q"
  system(command)

  File.exists?(repopath.join('.git')).should be_true
end

When /^I run "([^\"]*)"$/ do |cmd|
  if cmd.split(' ').first == "rump"
    command = "#{ROOT.join('bin', 'rump')} #{cmd.split[2..-1].join(' ')}"
  else
    command = cmd
  end

  silent_system(command).should be_true
end

Then /^I should have a git repository at "([^\"]*)"$/ do |reponame|
  repopath = @basedir.join(reponame)
  File.exists?(repopath.join('.git')).should be_true
end

