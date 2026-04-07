class OcrProcessJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find_by(id: receipt_id)
    return unless receipt

    receipt.perform_ocr!
  rescue => e
    Rails.logger.error "OcrProcessJob Error: #{e.message}"
  end
end
