class AiAdviceService
  def initialize(user_data)
    @user_data = user_data
  end

  def call
    client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])

    message = client.messages.create(
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1000,
      messages: [
        {
          role: "user",
          content: build_prompt
        }
      ]
    )

    message.content.first.text
    rescue => e
      Rails.logger.error "AI Advice Error: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      puts "AI Advice Error: #{e.class}: #{e.message}"
      nil
    end

  private

  def build_prompt
    <<~PROMPT
      あなたは家計管理のアドバイザーです。
      以下の支出データをもとに、日本語で簡潔なアドバイスを200文字以内で提供してください。

      【過去6ヶ月の支出合計】
      #{format_monthly_data}

      【今月のカテゴリ別支出】
      #{format_category_data}

      アドバイスは以下の観点で行ってください：
      - 支出の傾向
      - 節約できそうなポイント
      - 来月への提案

      ※ 数字がすべて0の場合は「データが少ないため分析できません。収支を記録してみましょう！」と返してください。
    PROMPT
  end

  def format_monthly_data
    @user_data[:monthly_expense].map do |d|
      "#{d[:label]}: #{d[:amount]}円"
    end.join("\n")
  end

  def format_category_data
    if @user_data[:category_expense].empty?
      "データなし"
    else
      @user_data[:category_expense].map do |d|
        "#{d[:label]}: #{d[:amount]}円"
      end.join("\n")
    end
  end
end