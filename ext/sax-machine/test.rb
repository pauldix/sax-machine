#!/usr/local/bin/ruby
puts `make`
load 'parser.rb'
require 'native'
p = SAXMachine::Parser.new
p.add_element("foo", "foo", [])
puts p.parse("<xml><title>hello title</title><foo>foo foo!</foo></xml>")
