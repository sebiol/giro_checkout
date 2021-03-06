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

    def pay(payment_data, payment_type)
      raise 'not allowed transaction must be in state initalized' unless status == Initialized
      raise 'no payment data' unless payment_data
      raise 'no valid payment data' unless payment_data.is_a? Hash
      #raise 'no valid payment data' unless payment_data.count == 1

      self.project_id = GiroCheckout.project_id(payment_type)
      raise "no_psp named '#{payment_type}' configured" if self.project_id.nil?
      raise "no_project_secret for id: #{self.project_id}" if GiroCheckout.project_secret(self.project_id).nil?

      #Following integrity checks could / should be part of the messages. Makes testing more modular and reduces complexity overall.
      #TODO: move to message
      if payment_type == 'paypal'
        Rails.logger.info 'start paypal transaction'
        Rails.logger.info "project id = #{self.project_id}"
        Rails.logger.info 'create message'
        msg = GcPaypaltransactionstartMessage.new( self )
      elsif payment_type == 'giropay'
        Rails.logger.info "#{payment_data['giropay']['BIC']} : #{payment_data['giropay']['IBAN']}"
        #Emulate giropay response
        return { 'rc' => '5031', 'msg' => 'Keine BIC angegeben' } if payment_data['giropay']['BIC'].blank?
        #Emulate giropay response
        return { 'rc' => '5026', 'msg' => 'BIC zu kurz' } if payment_data['giropay']['BIC'].length < 8
        return { 'rc' => '5026', 'msg' => 'BIC zu lang' } if payment_data['giropay']['BIC'].length > 11

        Rails.logger.info 'start giropay transaction'
        Rails.logger.info "project id = #{self.project_id}"
        Rails.logger.info 'create message'
        msg = GcGiropaytransactionstartMessage.new(
          self,
          payment_data['giropay']['BIC'],
          payment_data['giropay']['IBAN']
        )
      else
        raise "invalid or not supportet payment type"
      end

      #Check response & Log errors
      response = msg.make_api_call

      raise "unexpected response: #{response}" unless response.instance_of? Hash

      if response['rc'] == '0'
        #TODO: store URL?
        Rails.logger.info "transaction #{self.id} success"
        self.gcTransactionID = response['reference']
        self.status = GiroCheckout::Transaction::Started
        self.save
      else
        Rails.logger.error "transaction #{self.id} failed: #{response['rc']} - #{response['msg']}"
      end

      return response
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
