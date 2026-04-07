class ReceiptsController < ApplicationController
  before_action :set_transaction, only: [:new, :create]
  before_action :set_receipt, only: [:show, :destroy, :ocr]

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
    redirect_to receipt_path(@receipt), notice: "OCR処理を開始しました。しばらくお待ち下さい。"
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
end