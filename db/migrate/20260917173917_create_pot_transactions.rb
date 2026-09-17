class CreatePotTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :pot_transactions do |t|
      t.references :pot, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.date :transacted_on, null: false

      t.timestamps
    end
  end
end
