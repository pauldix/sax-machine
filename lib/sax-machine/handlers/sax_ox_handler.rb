require "ox"

module SAXMachine
  class SAXOxHandler < Ox::Sax
    include SAXAbstractHandler

    alias_method :text, :_value
    alias_method :cdata, :_value
    alias_method :end_element, :_end_element

    def initialize(object, on_error = nil, on_warning = nil)
      _initialize(object, on_error, on_warning)
      _reset
    end

    def attr(name, str)
      @attrs[name] = str
    end

    def attrs_done
      _start_element(@element || "", @attrs)
      _reset
    end

    def start_element(name)
      @element = name
    end

    def error(message, line, column)
      _error("#{message} on line #{line} column #{column}")
    end

    private

    def _reset
      @attrs = {}
      @element = nil
    end
  end
end
