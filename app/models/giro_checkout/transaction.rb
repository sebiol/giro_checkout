module GiroCheckout
  class Transaction < ActiveRecord::Base
    attr_accessible :amount, :currency, :project_id, :gcPSPTransactionID, :gcTransactionID, :purpose, :description, :status

    #Status codes
    Initialized   = 1001
    Started       = 1002
    Pending       = 1003

    Successful    = 2000

    Aborted       = 4000
    Failed        = 4000
    

    def rel_attributes
      result = Hash.new(nil)
      result['merchantTxId'] = self.id
      result['amount'] = amount
      result['currency'] = currency
      result['purpose'] = purpose
      return result
    end

    def build_paramstring
      "#{self.id}#{amount}#{currency}#{purpose}"
    end

  end
end
