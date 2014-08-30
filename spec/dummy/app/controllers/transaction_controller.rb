require_dependency "giro_checkout/application_controller"

module GiroCheckout
  class TransactionController < ApplicationController
    def start
      
      payment_type = "paypal" if params['payment'].has_key? 'paypal'
      payment_type = "giropay" if params['payment'].has_key? 'giropay'

      logger.info payment_type 

      transaction = { 
        'amount' => 10, 
        'currency' => 'EUR', 
        'purpose' => 'Meinrollstuhl Auswertung',
        'status' => '1'
      }

      redirect_to '/forms'
    end
  end
end
