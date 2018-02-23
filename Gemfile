source "http://rubygems.org"

gemspec

group :development, :test do
  gem 'rake'
  gem 'guard-rspec'
  gem 'simplecov', require: false, platforms: [:mri]
  gem 'coveralls', require: false, platforms: [:mri]

  gem 'activerecord', '~> 5.0.0'
  gem 'nokogiri', '>= 1.8.2'
  gem 'ox', '>= 2.1.2', platforms: [:mri, :rbx]
  gem 'oga', '>= 0.3.4'
end

group :test do
  gem 'sqlite3'
end
