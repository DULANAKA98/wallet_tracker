module Api
  class UsersController < BaseController
    def index
      users = User.all
      render json: users
    end
    
    def show
      render json: current_user.as_json(include: { transactions: { include: :product } })
    end
    
    def create
      user = User.new(user_params)
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def top_up
      amount = params[:amount].to_f
      
      if current_user.top_up(amount)
        render json: { 
          message: 'Top up successful', 
          new_balance: current_user.credit,
          transaction: current_user.transactions.last
        }
      else
        render json: { error: 'Invalid amount' }, status: :unprocessable_entity
      end
    end
    
    def purchase
      product = Product.find(params[:product_id])
      
      if current_user.purchase_product(product)
        render json: { 
          message: 'Purchase successful', 
          new_balance: current_user.credit,
          transaction: current_user.transactions.last
        }
      else
        render json: { error: 'Insufficient funds or invalid purchase' }, status: :unprocessable_entity
      end
    end
    
    def transactions
      transactions = current_user.transactions.recent.includes(:product)
      render json: transactions
    end
    
    private
    
    def user_params
      params.require(:user).permit(:name, :email, :credit)
    end
  end
end 