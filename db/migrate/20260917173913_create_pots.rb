class CreatePots < ActiveRecord::Migration[8.1]
  def change
    create_table :pots do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :target_cents, null: false
      t.string :color

      t.timestamps
    end
  end
end
