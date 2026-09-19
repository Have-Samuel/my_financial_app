class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :recipient, null: false
      t.string :avatar
      t.integer :amount_cents, null: false
      t.integer :direction, null: false
      t.date :occurred_on, null: false

      t.timestamps
    end

    add_index :transactions, [ :user_id, :occurred_on ]
    add_index :transactions, [ :user_id, :category_id ]
  end
end
