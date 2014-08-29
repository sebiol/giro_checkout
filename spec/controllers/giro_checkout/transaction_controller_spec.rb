require 'spec_helper'

module GiroCheckout
  describe TransactionController do
  
    describe "GET 'start'" do
      it "returns http success" do
        get 'start'
        response.should be_success
      end
    end
  
  end
end
