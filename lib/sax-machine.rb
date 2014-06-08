require "sax-machine/version"
require "sax-machine/sax_document"
require "sax-machine/sax_configure"
require "sax-machine/sax_config"
require "sax-machine/handlers/sax_abstract_handler"
require "sax-machine/handlers/sax_nokogiri_handler"

module SAXMachine
  @@handler = :nokogiri

  def self.handler
    @@handler
  end

  def self.handler=(handler)
    @@handler = handler
  end
end
