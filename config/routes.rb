GiroCheckout::Engine.routes.draw do
  get "transaction/start"

  get "callback/transaction_result", :as => 'txresult'
end
