module GiroCheckout
  class Transaction < ActiveRecord::Base
    attr_accessible :amount, :currency, :project_id, :gcPSPTransactionID, :gcTransactionID, :purpose, :description, :status

    def rel_attributes
      result = Hash.new(nil)
      result['merchantTxId'] = id
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
