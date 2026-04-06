class CreateReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :receipts do |t|
      t.integer :transaction_id
      t.string :image_path
      t.text :raw_text
      t.text :parsed_data
      t.string :status

      t.timestamps
    end

      add_index :receipts, :transaction_id
  end
end
