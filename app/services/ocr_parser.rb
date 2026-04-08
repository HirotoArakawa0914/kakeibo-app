class OcrParser
  def initialize(raw_text)
    @raw_text = raw_text
    @lines = raw_text.to_s.split("\n").map(&:strip).reject(&:empty?)
  end

  def parse
    {
      store_name: extract_store_name,
      date:       extract_date,
      amount:     extract_amount
    }
  end

  private

  def extract_store_name
    @lines.first
  end

  def extract_date
    @lines.each do |line|
      # YYYY/MM/DD または YYYY-MM-DD
      if line =~ /(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})/
        return Date.new($1.to_i, $2.to_i, $3.to_i)
      end
      # YYYY年MM月DD日
      if line =~ /(\d{4})年(\d{1,2})月(\d{1,2})日/
        return Date.new($1.to_i, $2.to_i, $3.to_i)
      end
      # MM/DD または MM月DD日（年なし）
      if line =~ /(\d{1,2})[\/](\d{1,2})/
        return Date.new(Date.today.year, $1.to_i, $2.to_i)
      end
    end
    Date.today
  rescue ArgumentError
    Date.today
  end

  def extract_amount
    candidates = []

    @lines.each do |line|
      if line =~ /合計|小計|お会計|総計|tax|total/i
        numbers = line.scan(/[\d,]+/).map { |n| n.gsub(",", "").to_i }
        candidates.concat(numbers.select { |n| n > 0 && n < 1_000_000 })
      end
    end

    # キーワード行がなければ¥や円記号がある行から探す
    if candidates.empty?
      @lines.each do |line|
        if line =~ /¥|円|￥/
          numbers = line.scan(/[\d,]+/).map { |n| n.gsub(",", "").to_i }
          candidates.concat(numbers.select { |n| n > 0 && n < 1_000_000 })
        end
      end
    end

    # それでもなければ100〜100000の範囲の数字から最大値
    if candidates.empty?
      @lines.each do |line|
        numbers = line.scan(/[\d,]+/).map { |n| n.gsub(",", "").to_i }
        candidates.concat(numbers.select { |n| n >= 100 && n <= 100_000 })
      end
    end

    candidates.max || 0
  end
end