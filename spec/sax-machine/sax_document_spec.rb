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

      it "should not overwrite the accessor when the element is not present" do
        document = @klass.new
        document.title = "Title"
        document.parse("<foo></foo>")
        document.title.should == "Title"
      end

      it "should overwrite the accessor when the element is present" do
        document = @klass.new
        document.title = "Old title"
        document.parse("<title>New title</title>")
        document.title.should == "New title"
      end

      it "should save the element text into an accessor" do
        document = @klass.parse("<title>My Title</title>")
        document.title.should == "My Title"
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
      
      describe "using the 'with' option" do
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
    end
  end
end
