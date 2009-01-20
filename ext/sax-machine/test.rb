#!/usr/local/bin/ruby
puts `make`
load 'parser.rb'
require 'native'
p = SAXCMachine::SAXCParser.new(String)
p.add_element("foo", "foo", "href", ["href", "http://pauldix.net"])
puts p.parse("<xml><title href=\"http://pauldix.net\">hello title</title><foo href=\"http://pauldix.net\" foo=\"bar\">foo foo!</foo></xml>")
