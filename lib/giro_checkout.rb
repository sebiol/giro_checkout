require "giro_checkout/engine"
require "giro_checkout/api/gc_message"
require "giro_checkout/api/gc_bankstatus_message"
require "giro_checkout/api/gc_transactionstart_message"
require "giro_checkout/api/gc_giropaytransactionstart_message"
require "giro_checkout/api/gc_paypaltransactionstart_message"

module GiroCheckout

  class << self
    attr_accessor :configuration

    def project_id(psp)
      @configuration.psps[psp]
    end

    def project_secret(project_id)
      @configuration.projects[project_id]['project_secret']
    end

    def callback_path
      "http://www.example.com#{Engine.routes.url_helpers.txresult_path}"
    end

    def message_url(msg_name)
      name = msg_name.match(/Gc(.*)Message$/)[1]
      return nil unless name
      #check for transactionstart
      if (name.match(/transactionstart$/))
        return configuration.message_urls['transactionstart']
      end
      configuration.message_urls[name.downcase]
    end

  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :merchantId
    attr_accessor :urlRedirect
    attr_accessor :psps
    attr_accessor :projects
    attr_accessor :message_urls

    def initialize
      @merchantId = '1234567'
      #project_id decoupled from payment service provider to provide functionality to change projectsecret and still use transactionstatus on old transactions
      @psps = { 
        'giropay' => '1234',
        'paypal' => '1234'
      }
      @projects = {
        '1234' => { 'project_secret' => 'secure' }
      }
      @message_urls = { 
        'bankstatus' => 'https://payment.girosolution.de/girocheckout/api/v2/giropay/bankstatus',
        'transactionstart' => 'https://payment.girosolution.de/girocheckout/api/v2/transaction/start',
        'transactionstatus' => 'https://payment.girosolution.de/girocheckout/api/v2/transaction/status'
      }
      @urlRedirect = 'http://www.example.com/callback/finish'
      @transaction_start_path = ''
    end
  end

end
