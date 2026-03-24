class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_type, null: false
      t.integer :amount, null: false
      t.date :date, null: false
      t.string :memo

      # Phase2以降で使用（今はnull許容）
      t.integer :category_id
      t.integer :user_id

      t.timestamps
    end
  end
end