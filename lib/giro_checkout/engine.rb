module GiroCheckout
  class Engine < ::Rails::Engine
    isolate_namespace GiroCheckout

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      #need ruby >= 1.9.3 to install factory_girl
      #g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
