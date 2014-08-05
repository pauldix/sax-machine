# SAX Machine

## Status

[![Gem Version](https://badge.fury.io/rb/sax-machine.svg)](http://badge.fury.io/rb/sax-machine)
[![Build Status](https://secure.travis-ci.org/pauldix/sax-machine.svg?branch=master)](http://travis-ci.org/pauldix/sax-machine?branch=master)
[![Coverage Status](https://img.shields.io/coveralls/pauldix/sax-machine.svg)](https://coveralls.io/r/pauldix/sax-machine?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/pauldix/sax-machine.svg)](https://codeclimate.com/github/pauldix/sax-machine)
[![Dependencies](https://gemnasium.com/pauldix/sax-machine.svg)](https://gemnasium.com/pauldix/sax-machine)

## Description

A declarative SAX parsing library backed by Nokogiri or Ox.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sax-machine'
```

And then execute:

```bash
$ bundle
```

## Usage

SAX Machine can use either `nokogiri` or `ox` as XML SAX handler.

To use **Nokogiri** add this line to your Gemfile:

```ruby
gem 'nokogiri', '~> 1.6'
```

To use **Ox** add this line to your Gemfile:

```ruby
gem 'ox', '>= 2.1.2'
```

You can also specify which handler to use manually, like this:

```ruby
SAXMachine.handler = :nokogiri
```

## Examples

Include `SAXMachine` in any class and define properties to parse:

```ruby
class AtomContent
  include SAXMachine
  attribute :type
  value :text
end

class AtomEntry
  include SAXMachine
  element :title
  # The :as argument makes this available through entry.author instead of .name
  element :name, as: :author
  element "feedburner:origLink", as: :url
  # The :default argument specifies default value for element when it's missing
  element :summary, class: String, default: "No summary available"
  element :content, class: AtomContent
  element :published
  ancestor :ancestor
end

class Atom
  include SAXMachine
  element :title
  # The :with argument means that you only match a link tag
  # that has an attribute of type: "text/html"
  element :link, value: :href, as: :url, with: {
    type: "text/html"
  }
  # The :value argument means that instead of setting the value
  # to the text between the tag, it sets it to the attribute value of :href
  element :link, value: :href, as: :feed_url, with: {
    type: "application/atom+xml"
  }
  elements :entry, as: :entries, class: AtomEntry
end
```

Then parse any XML with your class:

```ruby
feed = Atom.parse(xml_text)

feed.title # Whatever the title of the blog is
feed.url # The main URL of the blog
feed.feed_url # The URL of the blog feed

feed.entries.first.title # Title of the first entry
feed.entries.first.author # The author of the first entry
feed.entries.first.url # Permalink on the blog for this entry
feed.entries.first.summary # Returns "No summary available" if summary is missing
feed.entries.first.ancestor # The Atom ancestor
feed.entries.first.content # Instance of AtomContent
feed.entries.first.content.text # Entry content text
```

You can also use the elements method without specifying a class:

```ruby
class ServiceResponse
  include SAXMachine
  elements :message, as: :messages
end

response = ServiceResponse.parse("
  <response>
    <message>hi</message>
    <message>world</message>
  </response>
")
response.messages.first # hi
response.messages.last  # world
```

To limit conflicts in the class used for mappping, you can use the alternate
`SAXMachine.configure` syntax:

```ruby
class X < ActiveRecord::Base
  # This way no element, elements or ancestor method will be added to X
  SAXMachine.configure(X) do |c|
    c.element :title
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## LICENSE

The MIT License

Copyright (c) 2009-2014:

* [Paul Dix](http://www.pauldix.net)
* [Julien Kirch](http://www.archiloque.net)
* [Ezekiel Templin](http://zeke.templ.in)
* [Dmitry Krasnoukhov](http://krasnoukhov.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
