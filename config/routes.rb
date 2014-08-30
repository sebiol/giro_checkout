GiroCheckout::Engine.routes.draw do
  get "callback/transaction_result", :as => 'txresult'
end
