class User < ApplicationRecord
  has_secure_password
  has_many :transactions, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :credit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  
  before_validation :set_default_credit, on: :create
  
  def self.authenticate(email, password)
    user = find_by(email: email)
    user&.authenticate(password)
  end
  
  def can_afford?(amount)
    credit >= amount
  end
  
  def deduct_credit(amount)
    return false unless can_afford?(amount)
    update!(credit: credit - amount)
  end
  
  def add_credit(amount)
    update!(credit: credit + amount)
  end
  
  def purchase_product(product)
    return false unless can_afford?(product.price)
    
    ActiveRecord::Base.transaction do
      deduct_credit(product.price)
      transactions.create!(
        transaction_type: 'purchase',
        amount: product.price,
        product: product
      )
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def top_up(amount)
    return false if amount <= 0
    
    ActiveRecord::Base.transaction do
      add_credit(amount)
      transaction = transactions.build(
        transaction_type: 'top_up',
        amount: amount
      )
      transaction.save!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Top up failed: #{e.message}"
    false
  rescue => e
    Rails.logger.error "Top up error: #{e.message}"
    false
  end
  
  private
  
  def set_default_credit
    self.credit ||= 0
  end
end
