require 'sax-machine/handlers/sax_ox_handler'
require 'ox'

module SAXMachine
  class SAXOxHandlerManager
    def parse(args)
      document = args.fetch(:document)
      xml_text = args.fetch(:xml_text)
      on_error = args.fetch(:on_error)
      on_warning = args.fetch(:on_warning)

      Ox.sax_parse(
        SAXOxHandler.new(document, on_error, on_warning),
        StringIO.new(xml_text),
        {
          symbolize: false,
          convert_special: true,
          skip: :skip_return,
        }
      )
    end
  end
end
