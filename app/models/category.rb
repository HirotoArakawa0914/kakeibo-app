class Category < ApplicationRecord
    # validation
    validates :name,  presence: true, uniqueness: true
    validates :color, presence: true,
            format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "は#で始まる6桁の16進数で入力してください"}
    
    # association(Phase2以降で有効化)
    has_many :transactions, dependent: :nullify

    # scope
    scope :ordered, -> { order(:name) }
end
