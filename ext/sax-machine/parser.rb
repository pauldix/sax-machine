module SAXCMachine
  class SAXCParser
    attr_reader :parser_class
    
    def initialize(klass)
      @parser_class = klass.to_s
    end
    
    def set_value_from_attribute(setter, value)
      @target_object.send(setter, value)
    end
    
    def start_tag(setter)
      puts setter
      @setter = setter
    end
    
    def end_tag
      puts "#{@setter}: #{@chars}"
#      @target_object.send(@setter, @chars)
      @setter = nil
      @chars = nil
    end

    ###
    # Called when document starts parsing
    def start_document
    end

    ###
    # Called when document ends parsing
    def end_document
    end

    ###
    # Called at the beginning of an element
    # +name+ is the name of the tag with +attrs+ as attributes
    def start_element name, attrs = []
      puts "start - #{name} - #{attrs.inspect}"
    end

    ###
    # Called at the end of an element
    # +name+ is the tag name
    def end_element name
      puts "end - #{name}"
    end

    ###
    # Characters read between a tag
    # +string+ contains the character data
    def characters string
      @chars = string
      puts "characters called with: #{string}"
    end

    ###
    # Called when comments are encountered
    # +string+ contains the comment data
    def comment string
    end

    ###
    # Called on document warnings
    # +string+ contains the warning
    def warning string
    end

    ###
    # Called on document errors
    # +string+ contains the error
    def error string
    end

    ###
    # Called when cdata blocks are found
    # +string+ contains the cdata content
    def cdata_block string
    end
    
    def parse(xml_string)
      parse_memory(xml_string)
    end
  end
end