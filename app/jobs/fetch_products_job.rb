class FetchProductsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting to fetch products from API..."
    
    if Product.fetch_from_api
      Rails.logger.info "Successfully fetched products from API"
    else
      Rails.logger.error "Failed to fetch products from API"
    end
  end
end 