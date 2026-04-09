class DashboardController < ApplicationController
  def index
    @monthly_expense  = Transaction.monthly_expense_summary
    @category_expense = Transaction.category_expense_summary
    @monthly_balance  = Transaction.monthly_balance_summary
    @daily_expense    = Transaction.daily_expense_summary

    # APIキーがある場合のみAIアドバイスを生成
    if ENV["ANTHROPIC_API_KEY"].present?
      @ai_advice = AiAdviceService.new(
        monthly_expense:  @monthly_expense,
        category_expense: @category_expense
      ).call
    end
  end
end