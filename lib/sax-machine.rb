require "sax-machine/version"
require "sax-machine/sax_document"
require "sax-machine/sax_configure"
require "sax-machine/sax_config"
require 'sax-machine/sax_parser'

module SAXMachine
  def self.handler
    @@handler
  end

  def self.handler=(handler)
    require "sax-machine/handlers/sax_#{handler}_handler_manager"
    @@handler = handler
  end
end

begin
  SAXMachine.handler = :ox
rescue LoadError
  SAXMachine.handler = :nokogiri
end
