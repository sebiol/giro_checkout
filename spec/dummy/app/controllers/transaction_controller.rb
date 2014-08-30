class TransactionController < ApplicationController
  def start
    transaction = { 
      'amount' => 1000, 
      'currency' => 'EUR', 
      'purpose' => 'Meinrollstuhl Auswertung',
      'status' => GiroCheckout::Transaction::Initialized
    }

    logger.info params['payment']

    res = GiroCheckout.start_transaction(params['payment'], transaction)

    #Redirect to result url if contains url
    if res =~ /^https:/
      redirect_to res 
    else
      #If result dosen't contain a url redirect to form page with error
      session[:error] = res
      redirect_to '/forms'
    end
  end

  def finish
    case GiroCheckout.process_transaction params
    when :ok
      @msg = "Transaction ok"
    when :server_exception
      @msg = "Server exception"
    else
      @msg = "Transaction Abbort"
    end 
  end
end
