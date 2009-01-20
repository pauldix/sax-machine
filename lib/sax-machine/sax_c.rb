module SAXCMachine
  def self.included(base)
    base.extend ClassMethods
  end
  
  def parse(xml_text)
    parser = SAXCParser.new(self.class)
    parser.parse(self, xml_text)
    self
  end
  
  module ClassMethods
    
    def parse(xml_text)
      new.parse(xml_text)
    end
    
    def element(name, options = {})
      options[:as] ||= name.to_s
      options[:with] ||= {}
      with_attrs = options[:with].to_a.flatten.collect {|o| o.to_s}
      setter = "#{options[:as]}="
      if options[:value]
        sax_c_parser.add_element(name.to_s, setter, options[:value].to_s, with_attrs)
      else
        sax_c_parser.add_element(name.to_s, setter, nil, with_attrs)
      end
      
      attr_accessor options[:as]
    end
    
    def sax_c_parser
      @sax_c_parser ||= SAXCParser.new(self)
    end
  end
end