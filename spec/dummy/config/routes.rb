Rails.application.routes.draw do
  mount GiroCheckout::Engine => "/giro_checkout"

  get "/forms" => "forms#forms"
  get "/transaction/finish" => "transaction#finish"
  post "/transaction" => "transaction#start"
end
