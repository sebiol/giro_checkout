ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'webmock/rspec'
require 'lib/giro_checkout.rb'
require 'app/models/giro_checkout/transaction'
require 'factories/transactions'

Rails.backtrace_cleaner.remove_silencers!
WebMock.disable_net_connect!( :allow_localhost => true )

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods
end
