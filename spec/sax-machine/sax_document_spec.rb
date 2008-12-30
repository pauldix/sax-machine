require File.dirname(__FILE__) + '/../spec_helper'

describe "SAXMachine" do
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
  
  it "should not overwrite the accessor when the elment is not present" do
    document = @klass.new
    document.title = "Title"
    document.parse("<foo></foo>")
    document.title.should == "Title"
  end
  
  it "should save the element text into an accessor" do
    document = @klass.parse("<title>My Title</title>")
    document.title.should == "My Title"
  end
end
