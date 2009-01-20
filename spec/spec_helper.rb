require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

#puts `cd #{File.dirname(__FILE__)}/../ext/sax-machine && make && cp -f native.bundle ../../lib/sax-machine/`
require "sax-machine"

# Spec::Runner.configure do |config|
# end
