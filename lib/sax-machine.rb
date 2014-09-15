require "sax-machine/version"
require "sax-machine/sax_document"
require "sax-machine/sax_configure"
require "sax-machine/sax_config"

module SAXMachine
  def self.handler
    @@handler
  end

  def self.handler=(handler)
    require "sax-machine/handlers/sax_#{handler}_handler"
    @@handler = handler
  end
end

# Try handlers
[:ox, :oga].each do |handler|
  begin
    SAXMachine.handler = handler
    break
  rescue LoadError
  end
end

# Still no handler, use Nokogiri
if !SAXMachine.handler
  SAXMachine.handler = :nokogiri
end
