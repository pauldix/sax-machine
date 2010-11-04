# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sax-machine}
  s.version = "0.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philip MCmahon"]
  s.date = %q{2010-11-14}
  s.email = %q{philip@packetnode.com}
  s.files = [
    "lib/sax-machine.rb",
    "lib/sax-machine/sax_config.rb",
    "lib/sax-machine/sax_collection_config.rb",
    "lib/sax-machine/sax_element_config.rb",
    "lib/sax-machine/sax_document.rb",
    "lib/sax-machine/sax_handler.rb",
    "README.textile", "Rakefile",
    ".rspec",
    "spec/spec_helper.rb",
    "spec/sax-machine/sax_document_spec.rb"]
  s.homepage = %q{http://github.com/pauldix/sax-machine}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Declarative SAX Parsing with Nokogiri}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["> 0.0.0"])
    else
      s.add_dependency(%q<nokogiri>, ["> 0.0.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["> 0.0.0"])
  end
end