class Transaction < ApplicationRecord
  # association
  belongs_to :category, optional: true
  belongs_to :user, optional: true
  has_one :receipt, foreign_key: "transaction_id", dependent: :destroy

  # validation
  validates :transaction_type, presence: true,
            inclusion: { in: %w[income expense] }
  validates :amount, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  # scope（Phase2以降で活用）
  scope :income,  -> { where(transaction_type: "income") }
  scope :expense, -> { where(transaction_type: "expense") }
  scope :recent,  -> { order(date: :desc) }
  scope :by_month, ->(year, month) {
    where(date: Date.new(year, month, 1)..Date.new(year, month, -1))
  }

  # 月別支出合計 (6month分)
  def self.monthly_expense_summary
    (5.downto(0)).map do |i|
      date = i.month.ago
      year = date.year
      month = date.month
      total = by_month(year, month).expense.sum(:amount)
      { label: "#{year}/#{month}", amount: total }
    end
  end

  # カテゴリ別支出合計 (当月)
  def self.category_expense_summary(year = Date.today.year, month = Date.today.month)
    by_month(year, month)
       .expense
       .includes(:category)
       .group(:category_id)
       .sum(:amount)
       .map do |category_id, total|
          category = category_id ? Category.find_by(id: category_id) : nil
          {
            label: category&.name || "未分類",
            color: category&.color || "#CCCCCC",
            amount: total
          }
        end
  end

  # 月別収支バランス (6month分)
  def self.monthly_balance_summary
    (5.downto(0)).map do |i|
      date = i.month.ago
      year = date.year
      month = date.month
      income_total  = by_month(year, month).income.sum(:amount)
      expense_total = by_month(year, month).expense.sum(:amount)
      {
        label: "#{year}/#{month}",
        income: income_total,
        expense: expense_total,
        balance: income_total - expense_total
      }
    end
  end

  # 日別支出推移 (当月)
  def self.daily_expense_summary(year = Date.today.year, month = Date.today.month)
    by_month(year, month)
      .expense
      .group(:date)
      .sum(:amount)
      .map { |date, total| { label: date.strftime("%d"), amount: total } }
      .sort_by { |d| d[:label] }
  end
end