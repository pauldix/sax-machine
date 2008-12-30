module SAXMachine
  class SAXConfig
    def initialize()
      @top_level_elements = {}
      @collection_elements = {}
      @captured_elements = {}
    end
    
    def add_top_level_element(name, options)
      @top_level_elements[name.to_s] = options
    end
    
    def add_collection_element(name, options)
      @collection_elements[name.to_s] = options
    end
    
    def parse_element?(name)
      @top_level_elements.has_key?(name) || @collection_elements.has_key?(name)
    end
    
    def collection_element?(name)
      @collection_elements.has_key? name
    end
    
    def setter_for_element(name)
      "#{@top_level_elements[name][:as]}="
    end
    
    def accessor_for_collection(name)
      "#{@collection_elements[name][:as]}"
    end
    
    def add_parent_element(name)
    end
  end
end