module SAXMachine
  class SAXConfig
    def initialize()
      @top_level_elements = {}
      @captured_elements = {}
    end
    
    def add_top_level_element(name)
      @top_level_elements[name.to_s] = true
    end
    
    def parse_element?(name)
      @top_level_elements.has_key? name
    end
    
    def add_parent_element(name)
    end
  end
end