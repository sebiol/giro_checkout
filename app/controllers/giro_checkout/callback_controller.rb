require_dependency "giro_checkout/application_controller"
require 'openssl'

module GiroCheckout
  class CallbackController < ApplicationController
    def transaction_result
      #Check params & hash
      case GiroCheckout.process_transaction params
      when :ok
        render :nothing => true, :status => 200, :content_type => 'text/html'
      when :server_exception
        render :nothing => true, :status => 500, :content_type => 'text/html'
      else
        render :nothing => true, :status => 400, :content_type => 'text/html'
      end
    end
  end
end
