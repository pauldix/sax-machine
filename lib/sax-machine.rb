require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require "sax-machine/sax_document"
require "sax-machine/sax_handler"
require "sax-machine/sax_config"
require "sax-machine/sax_c_parser"
require "sax-machine/sax_c"
require "sax-machine/native"

module SAXMachine
  VERSION = "0.0.1"
end