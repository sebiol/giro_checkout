Rails.application.routes.draw do

  mount GiroCheckout::Engine => "/giro_checkout"
end
