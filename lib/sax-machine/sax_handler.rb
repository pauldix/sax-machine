require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    attr_reader :object

    def initialize(object)
      @object = object
      @parsed_configs = {}
    end

    def characters(string)
      if parsing_collection?
        @collection_handler.characters(string)
      elsif @element_config
        @value << string
      end
    end

    def cdata_block(string)
      characters(string)
    end

    def start_element(name, attrs = [])
      @name   = name
      @attrs  = attrs

      if parsing_collection?
        @collection_handler.start_element(@name, @attrs)

      elsif @collection_config = sax_config.collection_config(@name)
        @collection_handler = @collection_config.handler
        @collection_handler.start_element(@name, @attrs)

      elsif (element_configs = sax_config.element_configs_for_attribute(@name, @attrs)).any?
        parse_element_attributes(element_configs)
        set_element_config_for_element_value

      else
        set_element_config_for_element_value
      end
    end

    def end_element(name)
      if parsing_collection? && @collection_config.name == name
        @object.send(@collection_config.accessor) << @collection_handler.object
        reset_current_collection

      elsif parsing_collection?
        @collection_handler.end_element(name)

      elsif characaters_captured? && !parsed_config?
        mark_as_parsed
        @object.send(@element_config.setter, @value)
      end

      reset_current_tag
    end

    def characaters_captured?
      !@value.nil? && !@value.empty?
    end

    def parsing_collection?
      !@collection_handler.nil?
    end

    def parse_collection_instance_attributes
      instance = @collection_handler.object
      @attrs.each_with_index do |attr_name,index|
        instance.send("#{attr_name}=", @attrs[index + 1]) if index % 2 == 0 && instance.methods.include?("#{attr_name}=")
      end
    end

    def parse_element_attributes(element_configs)
      element_configs.each do |ec|
        unless parsed_config?(ec)
          @object.send(ec.setter, ec.value_from_attrs(@attrs))
          mark_as_parsed(ec)
        end
      end
      @element_config = nil
    end

    def set_element_config_for_element_value
      @value = ""
      @element_config = sax_config.element_config_for_tag(@name, @attrs)
    end

    def mark_as_parsed(element_config=nil)
      element_config ||= @element_config
      @parsed_configs[element_config] = true unless element_config.collection?
    end

    def parsed_config?(element_config=nil)
      element_config ||= @element_config
      @parsed_configs[element_config]
    end

    def reset_current_collection
      @collection_handler = nil
      @collection_config  = nil
    end

    def reset_current_tag
      @name   = nil
      @attrs  = nil
      @value  = nil
      @element_config = nil
    end

    def sax_config
      @object.class.sax_config
    end
  end
end