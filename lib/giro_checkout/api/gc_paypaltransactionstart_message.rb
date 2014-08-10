module GiroCheckout
  class GcPaypaltransactionstartMessage < GcTransactionstartMessage
  
    def initialize(transaction)
      super transaction
    end

    #Paypal has no unique attributes for the api invocation
    def build_paramstring
      super paramstring("")
    end
  end
end
