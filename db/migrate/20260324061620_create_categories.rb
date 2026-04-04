class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name,    null: false
      t.string :color,   null: false, default: "#000000"
      t.string :icon
      t.integer :user_id

      t.timestamps
    end
  end
end
