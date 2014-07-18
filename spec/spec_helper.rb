begin
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    add_filter '/spec/'
  end
rescue LoadError
end

require File.expand_path(File.dirname(__FILE__) + '/../lib/sax-machine')
if ENV['HANDLER'] == 'ox'
  require 'sax-machine/handlers/sax_ox_handler'
  SAXMachine.handler = :ox
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
