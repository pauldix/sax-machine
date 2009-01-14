require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    attr_reader :object
    
    def initialize(object)
      @object = object
      @parsed_elements = Hash.new {|h, k| h[k] = []}
    end
    
    def characters(string)
      if @collection_parse
        @collection_parse.characters(string)
      elsif @capture_characters && parse_current_element?
        @value ||= string
      end
    end
    
    def start_element(name, attrs = [])
      @capture_characters = true
      
      if @collection_parse
        @collection_parse.start_element(name, attrs)
      else
        @current_element_name = name
        @current_element_attrs = attrs
        
        if collection_class = @object.class.sax_config.collection_element?(@current_element_name)
          @collection_parse = SAXHandler.new(collection_class.new)
          
        elsif element_config = @object.class.sax_config.attribute_value_element?(@current_element_name, @current_element_attrs)
          
          @capture_characters = false
          unless value_element_parsed?(element_config)
            mark_as_parsed(name)
            @object.send(@object.class.sax_config.setter_for_element(name, @current_element_attrs), 
              @current_element_attrs[@current_element_attrs.index(element_config.value) + 1])
          end
        end
      end
    end
    
    def end_element(name)
      if @collection_parse
        if @object.class.sax_config.collection_element?(name)
          @object.send(@object.class.sax_config.accessor_for_collection(name)) << @collection_parse.object
          @collection_parse = nil
        else
          @collection_parse.end_element(name)
        end
      elsif @value
        mark_as_parsed(name)
        # if @object.class.sax_config.collection_element?(@current_element_name)
        #   @object.send(@object.class.sax_config.accessor_for_collection(name)) << @value
        # else
        @object.send(@object.class.sax_config.setter_for_element(name, @current_element_attrs), @value)
        # end
      end
      @current_element_name = nil
      @current_element_attrs = nil
      @value = nil
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
    
    def value_element_parsed?(element_config)
      if @parsed_elements.has_key?(@current_element_name)
        if element_config.has_with?
          intersects = @parsed_elements[@current_element_name].collect {|attrs| element_config.with & attrs}
          current_attrs_without_value = Array.new(@current_element_attrs)
          i = @current_element_attrs.index(element_config.value)
          current_attrs_without_value.delete_at i
          current_attrs_without_value.delete_at i
          intersects.detect {|attrs| attrs == current_attrs_without_value}
        else
          true
        end
      else
        false
      end
    end
    
    def remove_value_element(element)
      i = @current_element_attrs.index(element[:value])
      @current_element_attrs.delete_at i
      @current_element_attrs.delete_at i
    end
  end
end