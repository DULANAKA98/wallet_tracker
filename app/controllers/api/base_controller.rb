module Api
  class BaseController < ApplicationController
    before_action :authenticate_user!
    
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from StandardError, with: :internal_server_error
    
    private
    
    def authenticate_user!
      token = extract_token_from_header
      if token
        decoded_token = decode_token(token)
        @current_user = User.find(decoded_token['user_id'])
      else
        render json: { error: 'Authentication required' }, status: :unauthorized
      end
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
    
    def current_user
      @current_user
    end
    
    def extract_token_from_header
      header = request.headers['Authorization']
      header&.split(' ')&.last
    end
    
    def decode_token(token)
      JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })[0]
    end
    
    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end
    
    def unprocessable_entity(exception)
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
    
    def internal_server_error(exception)
      render json: { error: 'Internal server error' }, status: :internal_server_error
    end
  end
end 