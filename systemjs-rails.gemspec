$:.unshift File.expand_path("../lib", __FILE__)
require 'systemjs/rails/version'

Gem::Specification.new do |s|
  s.name    = 'systemjs-rails'
  s.version = Systemjs::Rails::VERSION

  s.homepage    = "http://github.com/josh/sprockets-es6"
  s.summary     = "SystemJS for the Asset pipeline and sprockets"
  s.description = <<-EOS
    A Sprockets transformer that converts ES6 code into vanilla ES5 with 6to5.
  EOS
  s.license = "MIT"

  s.files = [
    'lib/systemjs.rb',
    'lib/systemjs/rails.rb',
    'lib/systemjs/rails/version.rb',
    'lib/systemjs/rails/railtie.rb',
    'lib/systemjs/rails/builder_config.rb',
    'lib/systemjs/rails/system_js_processor.rb',
    'LICENSE',
    'README.md'
  ]

  s.add_dependency 'execjs'
  s.add_dependency 'sprockets', '~> 3.0.0.beta'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'

  s.authors = ['Tony Marklove']
  s.email   = 'tony@new-bamboo.co.uk'
end
