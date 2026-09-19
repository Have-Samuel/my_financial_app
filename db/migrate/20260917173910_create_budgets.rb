class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :limit_cents, null: false
      t.string :color

      t.timestamps
    end

    add_index :budgets, [ :user_id, :category_id ], unique: true
  end
end
