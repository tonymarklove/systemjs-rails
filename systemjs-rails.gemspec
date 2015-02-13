$:.unshift File.expand_path("../lib", __FILE__)
require 'systemjs/rails/version'

Gem::Specification.new do |s|
  s.name    = 'systemjs-rails'
  s.version = Systemjs::Rails::VERSION

  s.homepage    = "http://github.com/jjbananas/systemjs-rails"
  s.summary     = "SystemJS for the Asset pipeline and sprockets"
  s.description = <<-EOS
    Bringing SystemJS and JSPM to the Rails asset pipeline.
  EOS
  s.license = "MIT"

  s.extensions = ['Rakefile']

  s.files = Dir.glob("{lib}/**/*.rb")

  s.add_dependency 'execjs'
  s.add_dependency 'sprockets', '~> 3.0.0.beta'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'

  s.authors = ['Tony Marklove']
  s.email   = 'tony@new-bamboo.co.uk'
end
