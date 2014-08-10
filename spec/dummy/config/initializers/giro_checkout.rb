GiroCheckout.configure do |config|
  merchantId = '3609667'
  giropay = { 'projectId' => '8878', 'projectSecret' => 'giroTest' }
  message_urls = { 'bankstatus' => 'https://payment.girosolution.de/girocheckout/api/v2/giropay/bankstatus' } 
end
