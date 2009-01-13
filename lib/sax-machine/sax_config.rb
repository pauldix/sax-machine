module SAXMachine
  class SAXConfig
    def initialize()
      @top_level_elements = Hash.new {|h, k| h[k] = []}
      @collection_elements = {}
      @captured_elements = {}
    end
    
    def add_top_level_element(name, options)
      # stringify the :with options for faster comparisons later
      options[:with] = options[:with].to_a.flatten.collect {|o| o.to_s} if options.has_key?(:with)
      @top_level_elements[name.to_s] << options
    end
    
    def add_collection_element(name, options)
      @collection_elements[name.to_s] = options
    end
    
    def parse_element?(name, attrs)
      if @top_level_elements.has_key? name
        @top_level_elements[name].detect {|element| attrs_match?(element, attrs) }
      else
        @collection_elements.has_key?(name)
      end
    end
    
    def attrs_match?(element, attrs)
      with = element[:with]
      if with
        with == attrs
      else
        true
      end
    end
    
    def collection_element?(name)
      @collection_elements.has_key? name
    end
    
    def setter_for_element(name, attrs)
      "#{@top_level_elements[name].detect {|element| attrs_match?(element, attrs)}[:as]}="
    end
    
    def accessor_for_collection(name)
      "#{@collection_elements[name][:as]}"
    end
    
    def add_parent_element(name)
    end
  end
end