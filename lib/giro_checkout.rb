require "giro_checkout/engine"
require "giro_checkout/api/gc_message"
require "giro_checkout/api/gc_bankstatus_message"
require "giro_checkout/api/gc_transactionstart_message"
require "giro_checkout/api/gc_giropaytransactionstart_message"
require "giro_checkout/api/gc_paypaltransactionstart_message"
require "giro_checkout/api/gc_transactionstatus_message"

module GiroCheckout

  class << self
    attr_accessor :configuration

    def available_projects
      @psps.keys
    end

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

    def create_transaction(transaction_data, payment_type = nil)
      return nil unless transaction_data.instance_of? Hash

      #check data
      return :no_amount if transaction_data['amount'].nil?
      return :no_currency if transaction_data['currency'].nil?
      return :no_purpose if transaction_data['purpose'].nil?

      if payment_type.nil?
        return :no_proj_id if transaction_data['project_id'].nil?
      else
        proj_id = project_id(payment_type)
        return :no_psp_for_paymenttype if proj_id.nil?
        transaction_data['project_id'] = proj_id
      end

      transaction = GiroCheckout::Transaction.new(transaction_data)
      transaction.status = GiroCheckout::Transaction::Initialized
      transaction.save
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
        transaction.status = GiroCheckout::Transaction::Initialized
        transaction.save 
        transaction
      else 
        return transaction_by_id transaction_data 
      end
    end

    def start_transaction(payment_data, transaction_data)
      raise :deprecated
    end

    def process_transaction params
      unless ( \
        params['gcReference'] \
        and params['gcMerchantTxId'] \
        and params['gcBackendTxId'] \
        and params['gcAmount'] \
        and params['gcCurrency'] \
        and params['gcHash'] 
      )
        return :client_error
      end
      
      #Get Transaction
      begin
        transaction = GiroCheckout.transaction_by_id params['gcMerchantTxId']
      rescue
        Rails.logger.warn "No transaction with id: #{params['gcMerchantTxId']}"
        return :client_error
      end

      project_secret = GiroCheckout.project_secret(transaction.project_id)
      if project_secret.nil?
        Rails.logger.warn "No project secret for project id: #{transaction.project_id}"
        return :client_error
      end

      #build Paramstring to compare to hash
      paramstring = \
        "#{params['gcReference']}"\
        "#{params['gcMerchantTxId']}"\
        "#{params['gcBackendTxId']}"\
        "#{params['gcAmount']}"\
        "#{params['gcCurrency']}"\
        "#{params['gcResultPayment']}"
      Rails.logger.info paramstring

      digest = OpenSSL::Digest::Digest.new('md5')
      hash_calc = OpenSSL::HMAC.hexdigest(digest, project_secret, paramstring) 

      unless params['gcHash'] == hash_calc
        Rails.logger.warn "Hash missmatch"
        return :client_error
      end
      
      #TODO: check all attributes

      #update transaction
      new_status = GiroCheckout::Transaction::Pending
      if params['gcResultPayment']
        if params['gcResultPayment'] == '4000'
          new_status = GiroCheckout::Transaction::Successful
        elsif params['gcResultPayment'] == '4900'
          new_status = GiroCheckout::Transaction::Aborted
        else
          new_status = GiroCheckout::Transaction::Failed
        end
      end

      begin
        transaction.gcPSPTransactionID = params['gcBackendTxId']
        transaction.status = new_status
        transaction.save
      rescue
        Rails.logger.warn "Exception while updating transaction"
        return :server_exception
      end

      #send positive result
      if new_status == GiroCheckout::Transaction::Successful
        return :ok
      elsif new_status == GiroCheckout::Transaction::Aborted
        return :abort
      elsif new_status == GiroCheckout::Transaction::Pending
        return :pending 
      else
        return :failed
      end
    end


  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :merchantId
    attr_accessor :hostname
    attr_accessor :psps
    attr_accessor :projects
    attr_accessor :message_urls
    attr_accessor :transaction_start_path
    attr_accessor :transaction_return_path

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
