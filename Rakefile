require 'lib/sax-machine.rb'

task :test do
    sh 'rspec spec'
end

task :install do
  rm_rf "*.gem"
  puts `gem build sax-machine.gemspec`
  puts `sudo gem install sax-machine-#{SAXMachine::VERSION}.gem`
end
