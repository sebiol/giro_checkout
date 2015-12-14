module GiroCheckout
  class Transaction < ActiveRecord::Base
    attr_accessible :amount, :currency, :project_id, :gcPSPTransactionID, :gcTransactionID, :purpose, :description, :status

    #Status codes
    Initialized   = 1001
    Started       = 1002
    Pending       = 1003

    Successful    = 2000

    Aborted       = 4001
    Failed        = 4002
    
    def update_status()
#      raise "not implemented yet"
      msg = GcTransactionstatusMessage.new( self )
      response = msg.make_api_call
      #Check response & Log errors
    end

    def pay(payment_data)
      return :not_allowed unless status == Initialized
      raise 'no payment data' unless payment_data
      raise 'no valid payment data' unless payment_data.is_a? Hash
      raise 'no valid payment data' unless payment_data.count == 1

      #project_id needs to be set on creation
      #self.project_id = GiroCheckout.project_id(payment_data.keys[0])
      raise "no_psp named '#{payment_data.keys[0]}'" if self.project_id.nil?
      raise "no_project_secret for id: #{self.project_id}" if GiroCheckout.project_secret(self.project_id).nil?

      if payment_data.keys[0] == 'paypal'
        Rails.logger.info 'start paypal transaction'
        Rails.logger.info "project id = #{self.project_id}"
        Rails.logger.info 'create message'
        msg = GcPaypaltransactionstartMessage.new( self )
      elsif payment_data.keys[0] == 'giropay'
        return :invalid_BIC if payment_data['giropay']['BIC'].count < 8
        return :invalid_BIC if payment_data['giropay']['BIC'].count > 11
        return :no_BIC if payment_data['giropay']['BIC'].nil?

        Rails.logger.info 'start giropay transaction'
        Rails.logger.info 'create message'
        msg = GcGiropaytransactionstartMessage.new(
          self,
          payment_data['giropay']['BIC'], payment_data['giropay']['IBAN']
        )
      else
        return :invalid_payment_data
      end

      #Check response & Log errors
      response = msg.make_api_call

      return response unless response.instance_of? Hash
      return response['rc'] unless response['rc'] == '0'

      self.gcTransactionID = response['reference']
      self.status = GiroCheckout::Transaction::Started
      self.save

      return response['redirect']
    end

    def rel_attributes
      result = Hash.new(nil)
      result['merchantTxId'] = self.id
      result['amount'] = amount
      result['currency'] = currency
      result['purpose'] = purpose
      return result
    end

    def build_paramstring
      "#{self.id}#{amount}#{currency}#{purpose}"
    end

  end
end
