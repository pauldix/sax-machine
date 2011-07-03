require "nokogiri"

module SAXMachine
  class SAXHandler < Nokogiri::XML::SAX::Document
    attr_reader :stack

    def initialize(object)
      @stack = [[object, nil, ""]]
      @parsed_configs = {}
    end

    def characters(string)
      object, config, value = stack.last
      value << string
    end

    def cdata_block(string)
      characters(string)
    end

    def start_element(name, attrs = [])
      attrs.flatten!
      object, config, value = stack.last
      sax_config = object.class.respond_to?(:sax_config) ? object.class.sax_config : nil

      if sax_config
        if collection_config = sax_config.collection_config(name, attrs)
          stack.push [object = collection_config.data_class.new, collection_config, ""]
          object, sax_config, is_collection = object, object.class.sax_config, true

          if (attribute_config = object.class.respond_to?(:sax_config) && object.class.sax_config.attribute_configs_for_element(attrs))
            attribute_config.each { |ac| object.send(ac.setter, ac.value_from_attrs(attrs)) }
          end
        end
        sax_config.element_configs_for_attribute(name, attrs).each do |ec|
          unless parsed_config?(object, ec)
            object.send(ec.setter, ec.value_from_attrs(attrs))
            mark_as_parsed(object, ec)
          end
        end
        if !collection_config && element_config = sax_config.element_config_for_tag(name, attrs)
          new_object = element_config.data_class ? element_config.data_class.new : object
          stack.push [new_object, element_config, ""]

          if (attribute_config = new_object.class.respond_to?(:sax_config) && new_object.class.sax_config.attribute_configs_for_element(attrs))
            attribute_config.each { |ac| new_object.send(ac.setter, ac.value_from_attrs(attrs)) }
          end
        end
      end
    end

    def end_element(name)
      (object, tag_config, _), (element, config, value) = stack[-2..-1]
      return unless stack.size > 1 && config && config.name.to_s == name.to_s

      unless parsed_config?(object, config)
        if (element_value_config = config.data_class.respond_to?(:sax_config) && config.data_class.sax_config.element_values_for_element)
          element_value_config.each { |evc| element.send(evc.setter, value) }
        end

        if config.respond_to?(:accessor)
          object.send(config.accessor) << element
        else
          value = config.data_class ? element : value
          object.send(config.setter, value) unless value == ""
          mark_as_parsed(object, config)
        end
      end
      stack.pop
    end

    def mark_as_parsed(object, element_config)
      @parsed_configs[[object.object_id, element_config.object_id]] = true unless element_config.collection?
    end

    def parsed_config?(object, element_config)
      @parsed_configs[[object.object_id, element_config.object_id]]
    end
  end
end