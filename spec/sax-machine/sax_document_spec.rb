require File.dirname(__FILE__) + '/../spec_helper'

describe "SAXMachine" do
  describe "element" do
    describe "when parsing a single element" do
      before :each do
        @klass = Class.new do
          include SAXMachine
          element :title
        end
      end

      it "should provide an accessor" do
        document = @klass.new
        document.title = "Title"
        document.title.should == "Title"
      end
      
      it "should allow introspection of the elements" do
        @klass.column_names.should =~ [:title]
      end

      it "should not overwrite the setter if there is already one present" do
        @klass = Class.new do
          def title=(val)
            @title = "#{val} **"
          end
          include SAXMachine
          element :title
        end
        document = @klass.new
        document.title = "Title"
        document.title.should == "Title **"
      end
      describe "the class attribute" do
        before(:each) do
          @klass = Class.new do
            include SAXMachine
            element :date, :class => DateTime
          end
          @document = @klass.new
          @document.date = DateTime.now.to_s
        end
        it "should be available" do
          @klass.data_class(:date).should == DateTime
        end
      end
      describe "the required attribute" do
        it "should be available" do
          @klass = Class.new do
            include SAXMachine
            element :date, :required => true
          end
          @klass.required?(:date).should be_true
        end
      end
      
      it "should not overwrite the accessor when the element is not present" do
        document = @klass.new
        document.title = "Title"
        document.parse("<foo></foo>")
        document.title.should == "Title"
      end

      it "should overwrite the value when the element is present" do
        document = @klass.new
        document.title = "Old title"
        document.parse("<title>New title</title>")
        document.title.should == "New title"
      end

      it "should save the element text into an accessor" do
        document = @klass.parse("<title>My Title</title>")
        document.title.should == "My Title"
      end
      
      it "should save cdata into an accessor" do
        document = @klass.parse("<title><![CDATA[A Title]]></title>")
        document.title.should == "A Title"
      end

      it "should save the element text into an accessor when there are multiple elements" do
        document = @klass.parse("<xml><title>My Title</title><foo>bar</foo></xml>")
        document.title.should == "My Title"
      end

      it "should save the first element text when there are multiple of the same element" do
        document = @klass.parse("<xml><title>My Title</title><title>bar</title></xml>")
        document.title.should == "My Title"    
      end
    end

    describe "when parsing multiple elements" do
      before :each do
        @klass = Class.new do
          include SAXMachine
          element :title
          element :name
        end
      end

      it "should save the element text for a second tag" do
        document = @klass.parse("<xml><title>My Title</title><name>Paul</name></xml>")
        document.name.should == "Paul"
        document.title.should == "My Title"
      end
    end

    describe "when using options for parsing elements" do
      describe "using the 'as' option" do
        before :each do
          @klass = Class.new do
            include SAXMachine
            element :description, :as => :summary
          end
        end

        it "should provide an accessor using the 'as' name" do
          document = @klass.new
          document.summary = "a small summary"
          document.summary.should == "a small summary"
        end

        it "should save the element text into the 'as' accessor" do
          document = @klass.parse("<description>here is a description</description>")
          document.summary.should == "here is a description"
        end
      end
      
      describe "using the :with option" do
        describe "and the :value option" do
          before :each do
            @klass = Class.new do
              include SAXMachine
              element :link, :value => :href, :with => {:foo => "bar"}
            end
          end
          
          it "should save the value of a matching element" do
            document = @klass.parse("<link href='test' foo='bar'>asdf</link>")
            document.link.should == "test"
          end
          
          it "should save the value of the first matching element" do
            document = @klass.parse("<xml><link href='first' foo='bar' /><link href='second' foo='bar' /></xml>")
            document.link.should == "first"
          end
          
          describe "and the :as option" do
            before :each do
              @klass = Class.new do
                include SAXMachine
                element :link, :value => :href, :as => :url, :with => {:foo => "bar"}
                element :link, :value => :href, :as => :second_url, :with => {:asdf => "jkl"}
              end
            end
            
            it "should save the value of the first matching element" do
              document = @klass.parse("<xml><link href='first' foo='bar' /><link href='second' asdf='jkl' /><link href='second' foo='bar' /></xml>")
              document.url.should == "first"
              document.second_url.should == "second"
            end            
          end
        end
        
        describe "with only one element" do
          before :each do
            @klass = Class.new do
              include SAXMachine
              element :link, :with => {:foo => "bar"}
            end
          end

          it "should save the text of an element that has matching attributes" do
            document = @klass.parse("<link foo=\"bar\">match</link>")
            document.link.should == "match"
          end

          it "should not save the text of an element that doesn't have matching attributes" do
            document = @klass.parse("<link>no match</link>")
            document.link.should be_nil
          end

          it "should save the text of an element that has matching attributes when it is the second of that type" do
            document = @klass.parse("<xml><link>no match</link><link foo=\"bar\">match</link></xml>")
            document.link.should == "match"          
          end
          
          it "should save the text of an element that has matching attributes plus a few more" do
            document = @klass.parse("<xml><link>no match</link><link asdf='jkl' foo='bar'>match</link>")
            document.link.should == "match"
          end
        end
        
        describe "with multiple elements of same tag" do
          before :each do
            @klass = Class.new do
              include SAXMachine
              element :link, :as => :first, :with => {:foo => "bar"}
              element :link, :as => :second, :with => {:asdf => "jkl"}
            end
          end
          
          it "should match the first element" do
            document = @klass.parse("<xml><link>no match</link><link foo=\"bar\">first match</link><link>no match</link></xml>")
            document.first.should == "first match"
          end
          
          it "should match the second element" do
            document = @klass.parse("<xml><link>no match</link><link foo='bar'>first match</link><link asdf='jkl'>second match</link><link>hi</link></xml>")
            document.second.should == "second match"
          end
        end
      end # using the 'with' option
      
      describe "using the 'value' option" do
        before :each do
          @klass = Class.new do
            include SAXMachine
            element :link, :value => :foo
          end
        end
        
        it "should save the attribute value" do
          document = @klass.parse("<link foo='test'>hello</link>")
          document.link.should == 'test'
        end
        
        it "should save the attribute value when there is no text enclosed by the tag" do
          document = @klass.parse("<link foo='test'></link>")
          document.link.should == 'test'
        end
        
        it "should save the attribute value when the tag close is in the open" do
          document = @klass.parse("<link foo='test'/>")
          document.link.should == 'test'
        end
        
        it "should save two different attribute values on a single tag" do
          @klass = Class.new do
            include SAXMachine
            element :link, :value => :foo, :as => :first
            element :link, :value => :bar, :as => :second
          end
          document = @klass.parse("<link foo='foo value' bar='bar value'></link>")
          document.first.should == "foo value"
          document.second.should == "bar value"
        end
        
        it "should not fail if one of the attribute hasn't been defined" do
          @klass = Class.new do
            include SAXMachine
            element :link, :value => :foo, :as => :first
            element :link, :value => :bar, :as => :second
          end
          document = @klass.parse("<link foo='foo value'></link>")
          document.first.should == "foo value"
          document.second.should be_nil
        end
      end
      
      describe "when desiring both the content and attributes of an element" do
        before :each do
          @klass = Class.new do
            include SAXMachine
            element :link
            element :link, :value => :foo, :as => :link_foo
            element :link, :value => :bar, :as => :link_bar
          end
        end

        it "should parse the element and attribute values" do
          document = @klass.parse("<link foo='test1' bar='test2'>hello</link>")
          document.link.should == 'hello'
          document.link_foo.should == 'test1'
          document.link_bar.should == 'test2'
        end
      end
      
    end
  end
  
  describe "elements" do
    describe "when parsing multiple elements" do
      before :each do
        @klass = Class.new do
          include SAXMachine
          elements :entry, :as => :entries
        end
      end
      
      it "should provide a collection accessor" do
        document = @klass.new
        document.entries << :foo
        document.entries.should == [:foo]
      end
      
      it "should parse a single element" do
        document = @klass.parse("<entry>hello</entry>")
        document.entries.should == ["hello"]
      end
      
      it "should parse multiple elements" do
        document = @klass.parse("<xml><entry>hello</entry><entry>world</entry></xml>")
        document.entries.should == ["hello", "world"]
      end
      
      it "should parse multiple elements when taking an attribute value" do
        attribute_klass = Class.new do
          include SAXMachine
          elements :entry, :as => :entries, :value => :foo
        end
        doc = attribute_klass.parse("<xml><entry foo='asdf' /><entry foo='jkl' /></xml>")
        doc.entries.should == ["asdf", "jkl"]
      end
    end
    
    describe "when using the class option" do
      before :each do
        class Foo
          include SAXMachine
          element :title
        end
        @klass = Class.new do
          include SAXMachine
          elements :entry, :as => :entries, :class => Foo
        end
      end
      
      it "should parse a single element with children" do
        document = @klass.parse("<entry><title>a title</title></entry>")
        document.entries.size.should == 1
        document.entries.first.title.should == "a title"
      end
      
      it "should parse multiple elements with children" do
        document = @klass.parse("<xml><entry><title>title 1</title></entry><entry><title>title 2</title></entry></xml>")
        document.entries.size.should == 2
        document.entries.first.title.should == "title 1"
        document.entries.last.title.should == "title 2"
      end
      
      it "should not parse a top level element that is specified only in a child" do
        document = @klass.parse("<xml><title>no parse</title><entry><title>correct title</title></entry></xml>")
        document.entries.size.should == 1
        document.entries.first.title.should == "correct title"
      end
      
      it "should parse out an attribute value from the tag that starts the collection" do
        class Foo
          element :entry, :value => :href, :as => :url
        end
        document = @klass.parse("<xml><entry href='http://pauldix.net'><title>paul</title></entry></xml>")
        document.entries.size.should == 1
        document.entries.first.title.should == "paul"
        document.entries.first.url.should == "http://pauldix.net"
      end
    end    
  end
  
  describe "full example" do
    before :each do
      @xml = File.read('spec/sax-machine/atom.xml')
      class AtomEntry
        include SAXMachine
        element :title
        element :name, :as => :author
        element "feedburner:origLink", :as => :url
        element :summary
        element :content
        element :published
      end
        
      class Atom
        include SAXMachine
        element :title
        element :link, :value => :href, :as => :url, :with => {:type => "text/html"}
        element :link, :value => :href, :as => :feed_url, :with => {:type => "application/atom+xml"}
        elements :entry, :as => :entries, :class => AtomEntry
      end
    end # before
    
    it "should parse the url" do
      f = Atom.parse(@xml)
      f.url.should == "http://www.pauldix.net/"
    end
  end
end
