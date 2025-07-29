class FixProductIdNullConstraint < ActiveRecord::Migration[8.0]
  def change
    change_column_null :transactions, :product_id, true
  end
end
