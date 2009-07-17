require "sax-machine/sax_element_config"
require "sax-machine/sax_collection_config"

module SAXMachine
  class SAXConfig
    attr_reader :top_level_elements, :collection_elements

    def initialize
      @top_level_elements  = []
      @collection_elements = []
    end

    def add_top_level_element(name, options)
      @top_level_elements << ElementConfig.new(name, options)
    end

    def add_collection_element(name, options)
      @collection_elements << CollectionConfig.new(name, options)
    end

    def collection_config(name)
      @collection_elements.detect { |ce| ce.name.to_s == name.to_s }
    end

    def element_configs_for_attribute(name, attrs)
      @top_level_elements.select do |element_config|
        element_config.name == name &&
        element_config.has_value_and_attrs_match?(attrs)
      end
    end

    def element_config_for_tag(name, attrs)
      @top_level_elements.detect do |element_config|
        element_config.name == name &&
        element_config.attrs_match?(attrs)
      end
    end

  end
end