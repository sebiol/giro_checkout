class AllowNullForProjectIdOnTransactions < ActiveRecord::Migration
  def up
    change_column_null(:giro_checkout_transactions, :project_id, true)
  end

  def down
    change_column_null(:giro_checkout_transactions, :project_id, false)
  end
end
