require_dependency "giro_checkout/application_controller"
require 'openssl'

module GiroCheckout
  class CallbackController < ApplicationController
    def transaction_result
      #Check params & hash
      unless ( \
        params['gcReference'] \
        and params['gcMerchantTxId'] \
        and params['gcBackendTxId'] \
        and params['gcAmount'] \
        and params['gcCurrency'] \
        and params['gcHash'] 
      )
        render :nothing => true, :status => 400, :content_type => 'text/html'
      end
      
      #Get Transaction
      begin
        transaction = GiroCheckout.transaction_by_id params['gcMerchantTxId']
      rescue
        Rails.logger.warn "No transaction with id: #{params['gcMerchantTxId']}"
        render :nothing => true, :status => 400, :content_type => 'text/html'
      end

      project_secret = GiroCheckout.project_secret transaction.project_id
      if project_secret.nil?
        Rails.logger.warn "No project secret for project id: #{transaction.project_id}"
        render :nothing => true, :status => 400, :content_type => 'text/html'
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
      hash_calc = OpenSSL::HMAC.hexdigest(digest, project_secret, data) 

      unless params['gcHash'] == hash_calc
        Rails.logger.warn "Hash missmatch"
        render :nothing => true, :status => 400, :content_type => 'text/html'
      end
      
      #TODO: check all attributes

      #update transaction
      if params['gcResultPayment']
        if params['gcResultPayment'] == '4000'
          new_status = GiroCheckout::Transaction::Successful
        else
          new_status = GiroCheckout::Transaction::Failed
        end
      else
        new_status = GiroCheckout::Transaction::Pending
      end

      begin
        transaction.gcPSPTransactionID = params['gcBackendTxId']
        transaction.status = new_status
        transaction.save
      rescue
        Rails.logger.warn "Exception while updating transaction"
        render :nothing => true, :status => 500, :content_type => 'text/html'
      end

      #send positive result
      render :nothing => true, :status => 200, :content_type => 'text/html' 
    end
  end
end
