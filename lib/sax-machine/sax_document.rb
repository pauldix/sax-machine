require "nokogiri"

module SAXMachine
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  def parse(xml_text)
    sax_handler = SAXHandler.new(self)
    parser = Nokogiri::XML::SAX::Parser.new(sax_handler)
    parser.parse(xml_text)
    self
  end
  
  module ClassMethods
    
    def parse(xml_text)
      new.parse(xml_text)
    end
    
    def element(name)
      attr_accessor name
    end
    
  end
  
end