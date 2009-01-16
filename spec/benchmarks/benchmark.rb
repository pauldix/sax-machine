require 'rubygems'
require 'benchmark'
require 'happymapper'
require 'sax-machine'
include Benchmark
benchmark_iterations = 100

xml = File.read("spec/benchmarks/public_timeline.xml")
class Status
  include HappyMapper

  element :text, String
  element :source, String
end

class Statuses
  include SAXMachine
  
  elements :status, {:as => :statuses, :class => Class.new do
    include SAXMachine
    element :text
    element :source
  end}
end

benchmark do |t|
  t.report("happy mapper") do
    benchmark_iterations.times {
      Status.parse(xml)
    }
  end
  
  t.report("sax-machine") do
    benchmark_iterations.times {
      Statuses.parse(xml)
    }
  end
end

# xml = File.read("spec/benchmarks/amazon.xml")
# class HItem
#   include HappyMapper
# 
#   tag 'Item' # if you put class in module you need tag
#   element :asin, String, :tag => 'ASIN'
#   element :detail_page_url, String, :tag => 'DetailPageURL'
#   element :manufacturer, String, :tag => 'Manufacturer', :deep => true
# end
# class HItems
#   include HappyMapper
# 
#   tag 'Items' # if you put class in module you need tag
#   # element :total_results, Integer, :tag => 'TotalResults'
#   # element :total_pages, Integer, :tag => 'TotalPages'
#   has_many :items, Item
# end
# 
# class Item
#   include SAXMachine
#   
#   element :ASIN, :as => :asin
#   element :DetailPageUrl, :as => :detail_page_url
#   element :Manufacturer, :as => :manufacturer
# end
# class Items
#   include SAXMachine
#   elements :Item, :as => :items
# end
# 
# benchmark do |t|
#   t.report("sax-machine") do
#     benchmark_iterations.times {
#       Items.new.parse(xml)
#     }
#   end
#   
#   t.report("happymapper") do
#     benchmark_iterations.times {
#       HItems.parse(xml)
#     }
#   end
# end