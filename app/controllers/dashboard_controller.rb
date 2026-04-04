class DashboardController < ApplicationController
  def index
    @monthly_expense  = Transaction.monthly_expense_summary
    @category_expense = Transaction.category_expense_summary
    @monthly_balance  = Transaction.monthly_balance_summary
    @daily_expense    = Transaction.daily_expense_summary
  end
end
