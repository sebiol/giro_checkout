require 'spec_helper'

describe GiroCheckout::GcGiropaytransactionstartMessage do
  
  it "should not be able to send a http request" do
    transaction = Factory.create(:transaction)
    msg = GiroCheckout::GcGiropaytransactionstartMessage.new(transaction, 'DUSDXXXX')
    response = msg.make_api_call
    expect(response).to be_an_instance_of(String)
  end

end
