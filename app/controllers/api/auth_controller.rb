module Api
  class AuthController < BaseController
    skip_before_action :authenticate_user!, only: [:register, :login]
    
    def register
      user = User.new(user_params)
      
      if user.save
        token = generate_token(user.id)
        render json: {
          user: user.as_json(except: :password_digest),
          token: token,
          message: 'User registered successfully'
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def login
      user = User.authenticate(params[:email], params[:password])
      
      if user
        token = generate_token(user.id)
        render json: {
          user: user.as_json(except: :password_digest),
          token: token,
          message: 'Login successful'
        }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
    
    def logout
      # In a real app, you might want to blacklist the token
      render json: { message: 'Logged out successfully' }
    end
    
    private
    
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :credit)
    end
    
    def generate_token(user_id)
      JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
    end
  end
end