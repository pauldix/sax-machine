require "sax-machine/sax_element_config"
require "sax-machine/sax_collection_config"

module SAXMachine
  class SAXConfig
    attr_accessor :top_level_elements, :collection_elements
    
    def initialize
      @top_level_elements  = {}
      @collection_elements = {}
    end
    
    def columns
      @top_level_elements.map {|name, ecs| ecs }.flatten
    end
    
    def initialize_copy(sax_config)
      @top_level_elements = sax_config.top_level_elements.clone
      @collection_elements = sax_config.collection_elements.clone
    end

    def add_top_level_element(name, options)
      @top_level_elements[name.to_s] = [] unless @top_level_elements[name.to_s]
      @top_level_elements[name.to_s] << ElementConfig.new(name, options)
    end

    def add_collection_element(name, options)
      @collection_elements[name.to_s] = [] unless @collection_elements[name.to_s]
      @collection_elements[name.to_s] << CollectionConfig.new(name, options)
    end

    def collection_config(name, attrs)
      ces = @collection_elements[name.to_s]
      ces && ces.detect { |cc| cc.attrs_match?(attrs) }
    end

    def element_configs_for_attribute(name, attrs)
      tes = @top_level_elements[name.to_s]
      tes && tes.select { |ec| ec.has_value_and_attrs_match?(attrs) } || []
    end

    def element_config_for_tag(name, attrs)
      tes = @top_level_elements[name.to_s]
      tes && tes.detect { |ec| ec.attrs_match?(attrs) }
    end
  end
end