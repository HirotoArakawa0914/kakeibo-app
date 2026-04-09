class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]

  def index
    @transactions = current_user.transactions
                                .includes(:category, :receipt)
                                .recent
  end

  def show
  end

  def new
    @transaction = Transaction.new
    @categories = current_user.categories.ordered
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)
    if @transaction.save
      redirect_to transactions_path, notice: "収支を登録しました"
    else
      @categories = current_user.categories.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = current_user.categories.ordered
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "収支を更新しました"
    else
      @categories = current_user.categories.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: "収支を削除しました"
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_type, :amount, :date, :memo, :category_id
    )
  end
end