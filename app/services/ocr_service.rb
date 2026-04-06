require "google/cloud/vision/v1"

class OcrService
  def initialize(image_blob)
    @image_blob = image_blob
  end

  def call
    image_content = download_image
    response = request_vision_api(image_content)
    Rails.logger.info "OCR Response: #{response.inspect}"  # ← 追加
    text = extract_text(response)
    Rails.logger.info "OCR Text: #{text.inspect}"          # ← 追加
    text
  rescue => e
    nil
  end

  private

  def download_image
    @image_blob.download
  end

  def request_vision_api(image_content)
    client = Google::Cloud::Vision::V1::ImageAnnotator::Client.new do |config|
      config.credentials = Rails.root.join(ENV["GOOGLE_APPLICATION_CREDENTIALS"]).to_s
    end

    # バイナリデータをそのまま渡す（Base64エンコード不要）
    image = Google::Cloud::Vision::V1::Image.new(content: image_content)
    feature = Google::Cloud::Vision::V1::Feature.new(
      type: Google::Cloud::Vision::V1::Feature::Type::TEXT_DETECTION
    )

    request = Google::Cloud::Vision::V1::AnnotateImageRequest.new(
      image: image,
      features: [feature]
    )

    client.batch_annotate_images(requests: [request])
  end

  def extract_text(response)
    response.responses.first&.full_text_annotation&.text
  end
end