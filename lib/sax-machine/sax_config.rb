require "sax-machine/sax_element_config"
require "sax-machine/sax_collection_config"
require "sax-machine/sax_parent_config"

module SAXMachine
  class SAXConfig

    attr_accessor :top_level_elements, :collection_elements, :parents

    def initialize
      # Default value is an empty array
      @top_level_elements  = Hash.new { |hash, key| hash[key] = [] }
      @collection_elements = Hash.new { |hash, key| hash[key] = [] }
      @parents = []
    end

    def columns
      @top_level_elements.map {|name, ecs| ecs }.flatten
    end

    def initialize_copy(sax_config)
      super
      @top_level_elements = sax_config.top_level_elements.clone
      @collection_elements = sax_config.collection_elements.clone
      @parents = sax_config.parents.clone
    end

    def add_top_level_element(name, options)
      @top_level_elements[name.to_s] << ElementConfig.new(name, options)
    end

    def add_collection_element(name, options)
      @collection_elements[name.to_s] << CollectionConfig.new(name, options)
    end

    def add_parent(name, options)
      @parents << ParentConfig.new(name, options)
    end

    def collection_config(name, attrs)
      @collection_elements[name.to_s].detect { |cc| cc.attrs_match?(attrs) }
    end

    def element_configs_for_attribute(name, attrs)
      @top_level_elements[name.to_s].select { |ec| ec.has_value_and_attrs_match?(attrs) }
    end

    def element_config_for_tag(name, attrs)
      @top_level_elements[name.to_s].detect { |ec| ec.attrs_match?(attrs) }
    end
  end
end