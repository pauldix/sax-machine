require 'sax-machine/handlers/sax_nokogiri_handler'
require 'nokogiri'

module SAXMachine
  class SAXNokogiriHandlerManager
    def parse(args)
      document = args.fetch(:document)
      xml_text = args.fetch(:xml_text)
      on_error = args.fetch(:on_error)
      on_warning = args.fetch(:on_warning)

      handler = SAXNokogiriHandler.new(document, on_error, on_warning)
      parser = Nokogiri::XML::SAX::Parser.new(handler)
      parser.parse(xml_text) do |ctx|
        ctx.replace_entities = true
      end
    end
  end
end
