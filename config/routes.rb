GiroCheckout::Engine.routes.draw do
  match 'callback/transaction_result', :to => 'callback#transaction_result' ,:as => 'txresult'
end
