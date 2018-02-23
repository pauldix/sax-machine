require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'active_record'

describe "SAXMachine ActiveRecord integration" do
  before(:all) do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define(version: 1) do
      create_table :my_sax_models do |t|
        t.string :title
      end
    end

    class MySaxModel < ActiveRecord::Base
      SAXMachine.configure(MySaxModel) do |c|
        c.element :title
      end
    end
  end

  after do
    Object.send(:remove_const, :MySaxModel)
  end

  it "parses document" do
    document = MySaxModel.parse("<xml><title>My Title</title></xml>")
    expect(document.title).to eq("My Title")
  end
end
