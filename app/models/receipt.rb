class Receipt < ApplicationRecord
  belongs_to :ledger_transaction,
             class_name: "Transaction",
             foreign_key: "transaction_id",
             optional: true

  # status
  STATUSES = %w[pending processing done failed].freeze
  validates :status, inclusion: { in: STATUSES }

  # Active Storage
  has_one_attached :image

  # スコープ
  scope :pending,    -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :done,       -> { where(status: "done") }
  scope :failed,     -> { where(status: "failed") }

  def pending?    = status == "pending"
  def processing? = status == "processing"
  def done?       = status == "done"
  def failed?     = status == "failed"
end