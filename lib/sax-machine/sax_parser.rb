module SAXMachine
  class SAXParser
    attr_reader :handler_manager

    def initialize(handler)
      constant = "SAXMachine::SAX#{handler.to_s.capitalize}HandlerManager"
      @handler_manager = constantize(constant).new
    end

    def parse(args)
      #args: document, xml_text, on_error, on_warning
      handler_manager.parse(args)
    end

    private

    def constantize(constant)
      constant.split('::').inject(Object) do |memo, name|
        memo.const_get(name)
      end
    end
  end
end
