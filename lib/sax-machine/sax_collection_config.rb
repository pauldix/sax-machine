module SAXMachine
  class SAXConfig
    
    class CollectionConfig
      attr_reader :name
      
      def initialize(name, options)
        @name   = name.to_s
        @class  = options[:class]
        @as     = options[:as].to_s
      end
      
      def handler
        SAXHandler.new(@class.new)
      end
      
      def accessor
        as
      end
      
    protected
      
      def as
        @as
      end
      
      def class
        @class || @name
      end      
    end
    
  end
end