class OcrProcessJob < ApplicationJob
  queue_as :default

  def perform(receipt_id)
    receipt = Receipt.find_by(id: receipt_id)
    return unless receipt

    receipt.perform_ocr!

    if receipt.done?
      parsed = OcrParser.new(receipt.raw_text).parse
      receipt.update!(parsed_data: parsed.to_json)
    end
  rescue => e
    Rails.logger.error "OcrProcessJob Error: #{e.message}"
  end
end