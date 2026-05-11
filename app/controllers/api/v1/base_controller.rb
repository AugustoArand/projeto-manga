module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def not_found
        render json: { error: "Not found" }, status: :not_found
      end

      def cover_url_for(attachment)
        return nil unless attachment&.attached?
        url_for(attachment)
      end

      # ── Autenticação de usuário MangaVerse ────────────────────────────────────

      def authenticate_user!
        token = bearer_token
        return unauthorized! unless token.present?

        @current_session = UserSession.find_active(token)
        return unauthorized! unless @current_session

        @current_user = @current_session.user
      end

      def current_user
        @current_user
      end

      # MangaVerse usa X-User-Token; MangaDex usa Authorization: Bearer
      def bearer_token
        request.headers["X-User-Token"].presence ||
          request.headers["Authorization"]&.delete_prefix("Bearer ")
      end

      def unauthorized!
        render json: { error: "Autenticação necessária" }, status: :unauthorized
      end
    end
  end
end
