class TransactionsController < ApplicationController
    before_action :set_transaction, only: %i[show edit update destroy]

    def index
        @transactions = Transaction.includes(:category, :receipt).recent
    end

    def show
    end

    def new
        @transaction = Transaction.new
        @categories = Category.ordered
    end

    def create
        @transaction = Transaction.new(transaction_params)
        @transaction.user = current_user
        if @transaction.save
            redirect_to transactions_path, notice: "収支を登録しました"
        else
            @categories = Category.ordered
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @categories = Category.ordered
    end

    def update
        if @transaction.update(transaction_params)
            redirect_to transactions_path, notice: "収支を更新しました"
        else
            @categories = Category.ordered
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @transaction.destroy
        redirect_to transactions_path, notice: "収支を削除しました"
    end

    private

    def set_transaction
        @transaction = Transaction.find(params[:id])
    end

    def transaction_params
        params.require(:transaction).permit(
            :transaction_type, :amount, :date, :memo, :category_id
        )
    end
end