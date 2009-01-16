Gem::Specification.new do |s|
  s.name = %q{sax-machine}
  s.version = "0.0.1"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Dix"]
  s.date = %q{2009-1-13}
  s.email = %q{paul@pauldix.net}
  s.files = [
    "lib/sax-machine.rb",
    "lib/sax-machine/sax_config.rb",
    "lib/sax-machine/sax_document.rb",
    "lib/sax-machine/sax_handler.rb",
    "README.rdoc",
    "Rakefile",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/sax-machine/sax_document_spec.rb",
  ]
  s.homepage = %q{http://github.com/pauldix/sax-machine}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Declarative SAX Parsing with Nokogiri}
  s.has_rdoc = true
  s.add_dependency("nokogiri", ["> 0.0.0"])
end