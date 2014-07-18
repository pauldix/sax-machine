require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'active_record'

describe "ActiveRecord" do
  describe "integration" do
    before :each do
      class MySaxModel < ActiveRecord::Base
        SAXMachine.configure(MySaxModel) do |c|
          c.element :title
        end
      end
    end

    after :each do
      Object.send(:remove_const, :MySaxModel)
    end

    it "parses document" do
      document = MySaxModel.parse("<xml><title>My Title</title></xml>")
      expect(document.title).to eq("My Title")
    end
  end
end
