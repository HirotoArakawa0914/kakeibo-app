require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  # 正常系
  test "有効なデータで保存できる" do
    category = Category.new(
      name: "食費",
      color: "#FF5733"
    )
    assert category.valid?
  end

  test "アイコンなしでも有効" do
    category = Category.new(
      name: "交通費",
      color: "#33FF57",
      icon: nil
    )
    assert category.valid?
  end

  # name のバリデーション
  test "nameが空だと無効" do
    category = Category.new(
      name: nil,
      color: "#FF5733"
    )
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "nameが重複していると無効" do
    Category.create!(name: "食費", color: "#FF5733")
    category = Category.new(name: "食費", color: "#33FF57")
    assert_not category.valid?
    assert_includes category.errors[:name], "has already been taken"
  end

  # color のバリデーション
  test "colorが空だと無効" do
    category = Category.new(
      name: "食費",
      color: nil
    )
    assert_not category.valid?
    assert_includes category.errors[:color], "can't be blank"
  end

  test "colorが不正な形式だと無効" do
    category = Category.new(
      name: "食費",
      color: "red"
    )
    assert_not category.valid?
  end

  test "colorが#で始まる6桁の16進数だと有効" do
    category = Category.new(
      name: "食費",
      color: "#FF5733"
    )
    assert category.valid?
  end

  # スコープのテスト
  test "orderedスコープで名前順に取得できる" do
    Category.delete_all
    Category.create!(name: "食費", color: "#FF5733")
    Category.create!(name: "交通費", color: "#33FF57")
    assert_equal "交通費", Category.ordered.first.name
  end

  # アソシエーションのテスト
  test "カテゴリ削除時にTransactionのcategory_idがnullになる" do
    category = Category.create!(name: "食費", color: "#FF5733")
    transaction = Transaction.create!(
      transaction_type: "expense",
      amount: 1000,
      date: Date.today,
      category: category
    )
    category.destroy
    assert_nil transaction.reload.category_id
  end
end