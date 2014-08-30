Rails.application.routes.draw do
  mount GiroCheckout::Engine => "/giro_checkout"

  get "/forms" => "forms#forms"
  post "/transaction" => "transaction#start"
end
