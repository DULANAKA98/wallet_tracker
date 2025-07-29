class Product < ApplicationRecord
  has_many :transactions, dependent: :destroy
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :external_id, uniqueness: true, allow_nil: true
  
  scope :available, -> { where('price > 0') }
  
  def self.fetch_from_api
    response = HTTParty.get('https://fakestoreapi.com/products')
    return false unless response.success?
    
    products_data = JSON.parse(response.body)
    
    products_data.each do |product_data|
      product = find_or_initialize_by(external_id: product_data['id'])
      product.assign_attributes(
        name: product_data['title'],
        price: product_data['price'],
        description: product_data['description'],
        image_url: product_data['image']
      )
      # Force update the timestamp even if data is identical
      product.updated_at = Time.current
      product.save!
    end
    true
  rescue => e
    Rails.logger.error "Error fetching products: #{e.message}"
    false
  end
end
