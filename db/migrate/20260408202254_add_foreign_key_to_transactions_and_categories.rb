class AddForeignKeyToTransactionsAndCategories < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :transactions, :users, column: :user_id, on_delete: :nullify
    add_foreign_key :categories, :users, column: :user_id, on_delete: :nullify
  end
end