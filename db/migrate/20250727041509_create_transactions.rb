class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type
      t.decimal :amount
      t.references :product, null: true, foreign_key: true

      t.timestamps
    end
  end
end
