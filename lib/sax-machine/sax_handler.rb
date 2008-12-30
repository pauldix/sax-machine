require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    
    def initialize(object)
      @object = object
      @parsed_elements = {}
    end
    
    def characters(string)
      if parse_current_element?
        @value ||= string
      end
    end
    
    def start_element(name, attrs = [])
      @current_element_name = name
    end
    
    def end_element(name)
      if @value
        mark_as_parsed(name)
        if @object.class.sax_config.collection_element?(@current_element_name)
          @object.send(@object.class.sax_config.accessor_for_collection(name)) << @value
        else
          @object.send(@object.class.sax_config.setter_for_element(name), @value)
        end
        @value = nil
      end
    end
    
    def mark_as_parsed(name)
      @parsed_elements[name] = true
    end
    
    def parse_current_element?
      @object.parse_element?(@current_element_name) && (!@parsed_elements.has_key?(@current_element_name) || 
        @object.class.sax_config.collection_element?(@current_element_name))
    end
  end
end