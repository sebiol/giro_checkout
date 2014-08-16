require 'spec_helper'

describe "External URL call" do
  it "queries girocheckout" do
    uri = URI('https://payment.girosolution.de/girocheckout/api/v2/giropay/bankstatus')
    response Net::HTTP.get(uri)
    expect(response).to be_an_instance_of(String)
  end
end
