require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    
    def initialize(object)
      @object = object
      @parsed_elements = Hash.new {|h, k| h[k] = []}
    end
    
    def characters(string)
      if parse_current_element?
        @value ||= string
      end
    end
    
    def start_element(name, attrs = [])
      @current_element_name = name
      @current_element_attrs = attrs
      if element = @object.class.sax_config.attribute_value_element?(@current_element_name, @current_element_attrs)
        mark_as_parsed(name)
        @object.send(@object.class.sax_config.setter_for_element(name, @current_element_attrs), 
          @current_element_attrs[@current_element_attrs.index(element[:value]) + 1])
      end
    end
    
    def end_element(name)
      if @value
        mark_as_parsed(name)
        if @object.class.sax_config.collection_element?(@current_element_name)
          @object.send(@object.class.sax_config.accessor_for_collection(name)) << @value
        else
          @object.send(@object.class.sax_config.setter_for_element(name, @current_element_attrs), @value)
        end
        @value = nil
      end
    end
    
    def mark_as_parsed(name)
      @parsed_elements[name] << @current_element_attrs
    end
    
    def parse_current_element?
      (!current_element_parsed? || @object.class.sax_config.collection_element?(@current_element_name)) &&
        @object.parse_element?(@current_element_name, @current_element_attrs)
    end
    
    def current_element_parsed?
      @parsed_elements.has_key?(@current_element_name) &&
        @parsed_elements[@current_element_name].detect {|attrs| attrs == @current_element_attrs}
    end
  end
end