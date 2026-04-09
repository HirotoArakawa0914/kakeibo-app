class ReceiptsController < ApplicationController
  before_action :set_transaction, only: [:new, :create]
  before_action :set_receipt, only: [:show, :destroy, :ocr, :correct, :register]

  def new
    @receipt = Receipt.new
  end

  def create
    @receipt = Receipt.new(receipt_params)
    @receipt.ledger_transaction = @transaction

    if @receipt.save
      redirect_to transaction_path(@transaction), notice: "レシートをアップロードしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    transaction = @receipt.ledger_transaction
    @receipt.destroy
    redirect_to transaction_path(transaction), notice: "レシートを削除しました"
  end

  def ocr
    @receipt.update!(status: "processing")
    OcrProcessJob.perform_later(@receipt.id)
    redirect_to receipt_path(@receipt), notice: "OCR処理を開始しました。しばらくお待ちください。"
  end

  def upload
    @receipt = Receipt.new
    @receipt.image.attach(params[:image])

    if @receipt.save
      @receipt.update!(status: "processing")
      OcrProcessJob.perform_later(@receipt.id)
      redirect_to receipt_path(@receipt), notice: "レシートをアップロードしました。OCR処理中です。"
    else
      redirect_to new_transaction_path, alert: "アップロードに失敗しました。"
    end
  end

  def correct
    @parsed = @receipt.parsed_result
    @categories = current_user.categories.ordered

    if @receipt.ledger_transaction.present?
      @transaction_form = @receipt.ledger_transaction
    else
      @transaction_form = Transaction.new(
        date:             @parsed[:date],
        amount:           @parsed[:amount],
        transaction_type: "expense",
        memo:             @parsed[:store_name]
      )
    end
  end

  def register
    if @receipt.ledger_transaction.present?
      @transaction = @receipt.ledger_transaction
      success = @transaction.update(register_params)
    else
      @transaction = current_user.transactions.build(register_params)
      success = @transaction.save
    end

    if success
      @receipt.update!(
        ledger_transaction: @transaction,
        status: "done"
      )
      redirect_to transaction_path(@transaction), notice: "収支データを登録しました"
    else
      @parsed = @receipt.parsed_result
      @categories = current_user.categories.ordered
      @transaction_form = @transaction
      render :correct, status: :unprocessable_entity
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:transaction_id])
  end

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def register_params
    params.require(:transaction).permit(
      :transaction_type, :amount, :date, :memo, :category_id
    )
  end
end