class CreateGiroCheckoutTransactions < ActiveRecord::Migration
  def change
    create_table :giro_checkout_transactions do |t|
      t.integer :amount, :null => false
      t.string :currency, :null => false
      t.string :purpose, :null => false
      t.string :project_id, :null => false
      t.string :gcTransactionID
      t.string :gcPSPTransactionID
      t.string :description
      t.integer :status, :null => false

      t.timestamps
    end
  end
end
