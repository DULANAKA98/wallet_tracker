module Api
  class ProductsController < BaseController
    def index
      products = Product.available
      render json: products
    end
    
    def show
      product = Product.find(params[:id])
      render json: product
    end
    
    def fetch_from_api
      if Product.fetch_from_api
        render json: { message: 'Products fetched successfully' }
      else
        render json: { error: 'Failed to fetch products' }, status: :unprocessable_entity
      end
    end
  end
end 