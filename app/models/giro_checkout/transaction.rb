module GiroCheckout
  class Transaction < ActiveRecord::Base
    attr_accessible :amount, :currency, :project_id, :gcPSPTransactionID, :gcTransactionID, :purpose, :description, :status

    def build_paramstring
      "#{self.id}#{@amount}#{@currency}#{@purpose}"
    end

  end
end
