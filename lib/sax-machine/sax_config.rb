module SAXMachine
  class SAXConfig
    
    class ElementConfig
      attr_reader :with
      attr_reader :as
      attr_reader :value
      
      def initialize(name, options)
        @name = name
        
        if options.has_key?(:with)
          # stringify the :with options for faster comparisons later
          @with = options[:with].to_a.flatten.collect {|o| o.to_s}
        else
          @with = nil
        end
        
        if options.has_key?(:value)
          @value = options[:value].to_s
        else
          @value = nil
        end
        
        @as = options[:as]
      end

      def attrs_match?(attrs)
        if with
          with == (with & attrs)
        else
          true
        end
      end
      
      def has_value_and_attrs_match?(attrs)
        !@value.nil? && attrs_match?(attrs)
      end
      
      def has_with?
        !@with.nil?
      end
    end
    
    def initialize()
      @top_level_elements   = Hash.new { |h, k| h[k] = [] }
      @collection_elements  = {}
      @captured_elements    = {}
    end
    
    def add_top_level_element(name, options)
      @top_level_elements[name.to_s] << ElementConfig.new(name, options)
    end
    
    def add_collection_element(name, options)
      @collection_elements[name.to_s] = options
    end
    
    def parse_element?(name, attrs)
      if @top_level_elements.has_key? name
        @top_level_elements[name].detect do |element_config|
          element_config.attrs_match?(attrs)
        end
      else
        @collection_elements.has_key?(name)
      end
    end
    
    def collection_element?(name)
      if @collection_elements.has_key? name
        @collection_elements[name][:class] || name
      else
        false
      end
    end
    
    # returns true if this tag with these attrs are one we're saving the attributes for
    def attribute_value_element?(name, attrs)
      @top_level_elements.has_key?(name) &&
      top_level_element_matching_name_and_attrs(name, attrs)
    end
    
    def value_for_attribute_value_element(name, attrs)
      element = top_level_element_matching_name_and_attrs(name, attrs)
      attrs[attrs.index(element[:value]) + 1]
    end
    
    def setter_for_element(name, attrs)
      "#{@top_level_elements[name].detect { |element_config| element_config.attrs_match?(attrs) }.as}="
    end
    
    def top_level_element_matching_name_and_attrs(name, attrs)
      @top_level_elements[name].detect do |element_config|
        element_config.has_value_and_attrs_match?(attrs)
      end
    end
    
    def accessor_for_collection(name)
      @collection_elements[name][:as].to_s
    end
  end
end