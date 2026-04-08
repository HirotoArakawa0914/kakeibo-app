class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :transactions, dependent: :nullify
  has_many :categories,   dependent: :nullify
end