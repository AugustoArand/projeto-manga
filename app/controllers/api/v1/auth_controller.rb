module Api
  module V1
    class AuthController < BaseController
      def login
        result = MangadexAuthService.login(params[:username], params[:password])
        render json: {
          access_token:  result["access_token"],
          refresh_token: result["refresh_token"],
          expires_in:    result["expires_in"]
        }
      rescue MangadexAuthService::AuthenticationError => e
        render json: { error: e.message }, status: :unauthorized
      end

      def refresh
        result = MangadexAuthService.refresh(params[:refresh_token])
        render json: {
          access_token:  result["access_token"],
          refresh_token: result["refresh_token"],
          expires_in:    result["expires_in"]
        }
      rescue MangadexAuthService::AuthenticationError => e
        render json: { error: e.message }, status: :unauthorized
      end
    end
  end
end
