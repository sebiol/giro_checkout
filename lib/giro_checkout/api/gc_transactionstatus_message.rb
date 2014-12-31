module GiroCheckout
  class GcTransactionstatusMessage < GcMessage
    attr_accessor :transaction

    def initialize(transaction)
      super transaction.project_id
      @transaction = transaction

      raise :no_gcTransactionID if @transaction.gcTransactionID.nil?
      @parameters['reference'] = @transaction.gcTransactionID
    end

    #This method is to be called from child class via super(child_paramstring)
    #Handles common fields of the transactionstart message
    def build_paramstring()
      "#{@parameters['merchantId']}#{@parameters['projectId']}#{@parameters['reference']}"
    end

  end
end
