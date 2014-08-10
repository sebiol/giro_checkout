module GiroCheckout
  class GcBankstatusMessage < GcMessage

    def initialize(project_id, bic)
      super(project_id)
      @parameters['bic'] = bic
    end
    
    def build_paramstring
      "#{@parameters['merchantId']}#{@parameters['projectId']}#{@parameters['bic']}"
    end

  end
end
