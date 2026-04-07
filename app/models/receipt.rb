class Receipt < ApplicationRecord
  belongs_to :ledger_transaction,
             class_name: "Transaction",
             foreign_key: "transaction_id",
             optional: true

  # デフォルト値
  attribute :status, :string, default: "pending"

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

  # OCR実行
  def perform_ocr!
    return unless image.attached?

    update!(status: "processing")

    text = OcrService.new(image.blob).call

    if text.present?
      update!(raw_text: text, status: "done")
    else
      update!(status: "failed")
    end
  rescue => e
    Rails.logger.error "Receipt OCR Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    update!(status: "failed")
  end
end