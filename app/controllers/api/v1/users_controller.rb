module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!, only: %i[me logout update_profile]

      # POST /api/v1/users/register
      def register
        user = User.new(register_params)

        if user.save
          session = UserSession.create_for(user, device_info: request.user_agent)
          render json: {
            token: session.token,
            user:  user.as_api_json
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/login
      def login
        identifier = params[:identifier].to_s.strip.downcase
        user = User.find_by("lower(email) = ? OR lower(username) = ?", identifier, identifier)

        if user&.authenticate(params[:password])
          session = UserSession.create_for(user, device_info: request.user_agent)
          render json: {
            token: session.token,
            user:  user.as_api_json
          }
        else
          render json: { error: "Credenciais inválidas" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/users/logout
      def logout
        @current_session.destroy
        render json: { message: "Sessão encerrada" }
      end

      # GET /api/v1/users/me
      def me
        render json: { user: current_user.as_api_json }
      end

      # PATCH /api/v1/users/me
      def update_profile
        if current_user.update(profile_params)
          render json: { user: current_user.as_api_json }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def register_params
        params.permit(:name, :username, :email, :password, :password_confirmation)
      end

      def profile_params
        params.permit(:name, :avatar_color)
      end
    end
  end
end
