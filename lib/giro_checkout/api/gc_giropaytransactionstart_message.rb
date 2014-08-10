module GiroCheckout
  class GcGiropaytransactionstartMessage < GcTransactionstartMessage
  
    #Todo: optional fields 1..5
    def initialize(transaction, bic, iban = nil)
      super transaction
      @parameters['bic'] = bic
      @parameters['iban'] = iban if iban
    end

    def build_paramstring
      paramstring = "#{@parameters['bic']}#{@parameters['iban']}"
      super paramstring
    end
  end
end
