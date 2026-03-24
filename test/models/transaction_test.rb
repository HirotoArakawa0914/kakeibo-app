require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  # 正常系
  test "有効なデータで保存できる" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: 1000,
      date: Date.today,
      memo: "テスト"
    )
    assert transaction.valid?
  end

  # transaction_type のバリデーション
  test "transaction_typeが空だと無効" do
    transaction = Transaction.new(
      transaction_type: nil,
      amount: 1000,
      date: Date.today
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:transaction_type], "can't be blank"
  end

  test "transaction_typeがincome/expense以外だと無効" do
    transaction = Transaction.new(
      transaction_type: "invalid",
      amount: 1000,
      date: Date.today
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:transaction_type], "is not included in the list"
  end

  test "transaction_typeがincomeだと有効" do
    transaction = Transaction.new(
      transaction_type: "income",
      amount: 1000,
      date: Date.today
    )
    assert transaction.valid?
  end

  # amount のバリデーション
  test "amountが空だと無効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: nil,
      date: Date.today
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:amount], "can't be blank"
  end

  test "amountが0以下だと無効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: 0,
      date: Date.today
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:amount], "must be greater than 0"
  end

  test "amountが負だと無効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: -1,
      date: Date.today
    )
    assert_not transaction.valid?
  end

  test "amountが小数だと無効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: 1.5,
      date: Date.today
    )
    assert_not transaction.valid?
  end

  # date のバリデーション
  test "dateが空だと無効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: 1000,
      date: nil
    )
    assert_not transaction.valid?
    assert_includes transaction.errors[:date], "can't be blank"
  end

  # memo は任意項目
  test "memoが空でも有効" do
    transaction = Transaction.new(
      transaction_type: "expense",
      amount: 1000,
      date: Date.today,
      memo: nil
    )
    assert transaction.valid?
  end

  # スコープのテスト
  test "recentスコープで日付降順に取得できる" do
    Transaction.delete_all
    old = Transaction.create!(transaction_type: "expense", amount: 500, date: 1.week.ago)
    new_t = Transaction.create!(transaction_type: "income", amount: 1000, date: Date.today)
    assert_equal new_t, Transaction.recent.first
  end

  test "incomeスコープで収入のみ取得できる" do
    Transaction.delete_all
    Transaction.create!(transaction_type: "income", amount: 1000, date: Date.today)
    Transaction.create!(transaction_type: "expense", amount: 500, date: Date.today)
    assert_equal 1, Transaction.income.count
  end

  test "expenseスコープで支出のみ取得できる" do
    Transaction.delete_all
    Transaction.create!(transaction_type: "income", amount: 1000, date: Date.today)
    Transaction.create!(transaction_type: "expense", amount: 500, date: Date.today)
    assert_equal 1, Transaction.expense.count
  end
end