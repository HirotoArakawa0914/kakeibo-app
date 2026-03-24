class Transaction < ApplicationRecord
  # association
  belongs_to :category, optional: true  # ← 追加（Phase2まではnull許容）

  # validation
  validates :transaction_type, presence: true,
            inclusion: { in: %w[income expense] }
  validates :amount, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  # scope（Phase2以降で活用）
  scope :income,  -> { where(transaction_type: "income") }
  scope :expense, -> { where(transaction_type: "expense") }
  scope :recent,  -> { order(date: :desc) }
end