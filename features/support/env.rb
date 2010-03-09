#!/usr/bin/env ruby 

ROOT = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), '..', '..')))

def silent_system(cmd)
  command = [cmd, "2>&1 /dev/null"].join(' ')
  system(command)
end
