require 'sax-machine/handlers/sax_abstract_handler'
require 'ox'

module SAXMachine
  class SAXOxHandler < Ox::Sax
    include SAXAbstractHandler

    def initialize(*args)
      _initialize(*args)
      _reset_element
    end

    def attr(name, str)
      @attrs[name] = str
    end

    def attrs_done
      _start_element(@element, @attrs)
      _reset_element
    end

    def start_element(name)
      @element = name
    end

    def error(message, line, column)
      _error("#{message} on line #{line} column #{column}")
    end

    alias_method :text, :_characters
    alias_method :cdata, :_characters
    alias_method :end_element, :_end_element

    private

    def _reset_element
      @attrs = {}
      @element = ""
    end
  end
end
