require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    
    def initialize(object)
      @object = object
    end
    
    def characters(string)
      @object.title = string
    end
    
  end
end