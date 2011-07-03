module SAXMachine
  class SAXConfig

    class ParentConfig
      attr_reader :name, :setter

      def initialize(name, options)
        @name = name.to_s

        @as = options[:as]
        @setter = "#{@as}="
      end

      def column
        @as || @name.to_sym
      end

    end

  end
end