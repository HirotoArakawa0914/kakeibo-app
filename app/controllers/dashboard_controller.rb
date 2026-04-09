class DashboardController < ApplicationController
  def index
    @monthly_expense  = current_user.transactions.monthly_expense_summary
    @category_expense = current_user.transactions.category_expense_summary
    @monthly_balance  = current_user.transactions.monthly_balance_summary
    @daily_expense    = current_user.transactions.daily_expense_summary

    if ENV["ANTHROPIC_API_KEY"].present?
      @ai_advice = AiAdviceService.new(
        monthly_expense:  @monthly_expense,
        category_expense: @category_expense
      ).call
    end
  end
end