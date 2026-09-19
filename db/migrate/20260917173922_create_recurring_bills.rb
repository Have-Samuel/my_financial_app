class CreateRecurringBills < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_bills do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :amount_cents, null: false
      t.integer :due_day, null: false
      t.integer :status, null: false, default: 0
      t.string :avatar

      t.timestamps
    end

    add_index :recurring_bills, [ :user_id, :due_day ]
  end
end
