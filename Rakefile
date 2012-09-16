require 'rake'
require 'rspec/core/rake_task'

def java?
  !! (RUBY_PLATFORM =~ /java/)
end

def rubinius?
  !! (RUBY_ENGINE =~ /rbx/)
end

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = ['--1.9'] if java?
  spec.ruby_opts = ['-X19'] if rubinius?
  spec.rspec_opts = ['-c', '--format d']
  spec.verbose = true
  spec.fail_on_error = true
end

