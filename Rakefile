require "rspec/core/rake_task"
require File.dirname(__FILE__) + '/lib/sax-machine.rb'

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

task :default => [:spec]

task :test do
    sh 'rspec spec'
end

task :install do
  rm_rf "*.gem"
  puts `gem build sax-machine.gemspec`
  puts `sudo gem install sax-machine-#{SAXMachine::VERSION}.gem`
end
