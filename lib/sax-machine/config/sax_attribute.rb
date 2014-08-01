module SAXMachine
  class SAXConfig
    class AttributeConfig
      attr_reader :name, :setter

      def initialize(name, options)
        @name     = name.to_s
        @as       = options[:as]
        @setter   = "#{@as}="
        @required = options[:required]
      end

      def column
        @as || @name.to_sym
      end

      def required?
        !!@required
      end

      def value_from_attrs(attrs)
        attrs.fetch(@name, nil)
      end

      def attrs_match?(attrs)
        attrs.key?(@name) || attrs.value?(@name)
      end
      alias_method :has_value_and_attrs_match?, :attrs_match?

      def collection?
        false
      end
    end
  end
end
