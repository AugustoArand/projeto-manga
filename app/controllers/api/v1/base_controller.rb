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
    end
  end
end
