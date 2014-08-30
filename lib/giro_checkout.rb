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

    def urlNotify
      "#{@configuration.hostname}#{Engine.routes.url_helpers.txresult_path}"
    end

    def urlRedirect
      "#{@configuration.hostname}#{@configuration.transaction_return_path}"
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

    def transaction_by_id(id)
      GiroCheckout::Transaction.find id
    end

    def get_transaction(transaction_data, payment_type = nil)
      if transaction_data.instance_of? GiroCheckout::Transaction
        transaction_data.save unless transaction_data.id
        return transaction_data
      elsif transaction_data.instance_of? Hash
        unless transaction_data['project_id']
          return :no_payment_type unless payment_type 
          transaction_data['project_id'] = project_id(payment_type) 
        end
        transaction = GiroCheckout::Transaction.new(transaction_data)
        transaction.save 
        transaction
      else 
        return transaction_by_id transaction_data 
      end
    end

    def start_transaction(payment_data, transaction_data)
      raise 'no payment data' unless payment_data
      raise 'no valid payment data' unless payment_data.is_a? Hash
      raise 'no valid payment data' if payment_data.count < 1
      
      msg = nil
      if payment_data.has_key? 'paypal'
        Rails.logger.info 'start paypal transaction'
        Rails.logger.info 'get transaction'
        transaction = get_transaction(transaction_data, 'paypal')
        Rails.logger.info 'create message'
        msg = GcPaypaltransactionstartMessage.new( transaction )
      elsif payment_data.has_key? 'giropay'
        Rails.logger.info 'start giropay transaction'
        Rails.logger.info 'get transaction'
        transaction = get_transaction(transaction_data, 'giropay')
        Rails.logger.info 'create message'
        msg = GcGiropaytransactionstartMessage.new(
          transaction,
          payment_data['giropay']['BIC'], payment_data['giropay']['IBAN']
        )
      else
        raise 'no valid payment data'
      end
      
      #Check response & Log errors
      response = msg.make_api_call
      
      return response unless response.instance_of? Hash
      return response['rc'] unless response['rc'] == '0'

      transaction.gcTransactionID = response['reference']
      transaction.status = GiroCheckout::Transaction::Started
      transaction.save

      return response['redirect']
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
    attr_accessor :transaction_start_path

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

      @hostname = 'https://www.example.com'
      @transaction_return_path = '/callback/finish'
      @transaction_start_path = '/transaction'
    end
  end

end
