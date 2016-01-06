class TransactionController < ApplicationController
  def start
    transaction_data = { 
      'amount' => 1000, 
      'currency' => 'EUR', 
      'purpose' => 'Meinrollstuhl Auswertung',
    }

    logger.info params['method']
    logger.info params['payment'].inspect

    transaction = GiroCheckout.create_transaction(transaction_data)
    logger.debug transaction
    res = transaction.pay(params['payment'], params['method'])
    logger.info res.inspect

    #Redirect to result url if contains url
    if res.has_key?('redirect') && res['redirect'] != nil
      redirect_to res['redirect']
    else
      #If result dosen't contain a url redirect to form page with error
      session[:error] = "#{res['rc']} - #{res['msg']}"
      redirect_to '/forms'
    end
  end

  def finish
    case GiroCheckout.process_transaction params
    when :ok
      @msg = "Transaction ok"
    when :server_exception
      @msg = "Server exception"
    when :abort
      @msg = "Transaation aborted"
    else
      @msg = "Transaction Failed"
    end 
  end
end
