require "spec"
require "spec/rake/spectask"
require 'lib/sax-machine.rb'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :install do
  rm_rf "*.gem"
  puts `gem build sax-machine.gemspec`
  puts `sudo gem install sax-machine-#{SAXMachine::VERSION}.gem`
end

task :remove_compiled_files do
  puts `rm ext/sax-machine/native.bundle`
  puts `rm ext/sax-machine/parser.o`
  puts `rm lib/sax-machine/native.bundle`
end