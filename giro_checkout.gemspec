$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "giro_checkout/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "giro_checkout"
  s.version     = GiroCheckout::VERSION
  s.authors     = ["sebiol"]
  s.email       = ["mail@sebiol.de"]
  s.homepage    = "https://github.com/sebiol/giro_checkout"
  s.summary     = "Ruby Interface to the girocheckout API"
  s.description = "Provides a Rails plugin for interaction with th girocheckout API. Girocheckout handles payment transactions with various payment service providers."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.5"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency('rspec-rails', '2.13.2')
  #Dependencies require ruby 1.9.3
  #s.add_development_dependency('nokogiri', '~> 1.5.10')
  #s.add_development_dependency('capybara', '2.0.3')
  #s.add_development_dependency('factory_girl_rails', '~> 2.0.0')
end
