require 'sax-machine/handlers/sax_abstract_handler'
require 'nokogiri'

module SAXMachine
  class SAXNokogiriHandler < Nokogiri::XML::SAX::Document
    include SAXAbstractHandler

    alias_method :initialize, :_initialize
    alias_method :characters, :_characters
    alias_method :cdata_block, :_characters
    alias_method :start_element, :_start_element
    alias_method :end_element, :_end_element
    alias_method :error, :_error
    alias_method :warning, :_warning
  end
end
