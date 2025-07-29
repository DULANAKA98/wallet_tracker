class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :product, optional: true
  
  validates :transaction_type, presence: true, inclusion: { in: %w[purchase top_up] }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product, presence: true, if: -> { transaction_type == 'purchase' }
  
  scope :purchases, -> { where(transaction_type: 'purchase') }
  scope :top_ups, -> { where(transaction_type: 'top_up') }
  scope :recent, -> { order(created_at: :desc) }
  
  def purchase?
    transaction_type == 'purchase'
  end
  
  def top_up?
    transaction_type == 'top_up'
  end
end
