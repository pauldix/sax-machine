require File.dirname(__FILE__) + '/../spec_helper'

describe "SAXMachine" do
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
end
