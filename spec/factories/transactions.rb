FactoryGirl.define do
  factory :transaction, :class => GiroCheckout::Transaction do |f|
    f.amount 100
    f.currency 'EUR'
    f.purpose 'Testpayment'
    f.status 'neu'
    f.project_id '1234'
  end
end
