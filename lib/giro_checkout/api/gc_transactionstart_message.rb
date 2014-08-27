module GiroCheckout
  class GcTransactionstartMessage < GcMessage
    attr_accessor :transaction

    def initialize(transaction)
      super transaction.project_id
      @transaction = transaction
      #merge transaction.rel_attributes into parameters so they are passed as post arguments in the api invocation
      @parameters.merge!(transaction.rel_attributes)
    end

    #This method is to be called from child class via super(child_paramstring)
    #Handles common fields of the transactionstart message
    def build_paramstring(child_paramstring)
      "#{@parameters['merchantId']}#{@parameters['projectId']}#{@transaction.build_paramstring}#{child_paramstring}#{GiroCheckout.configuration.urlRedirect}#{GiroCheckout.callback_path}"
    end

  end
end
