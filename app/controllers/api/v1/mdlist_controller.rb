module Api
  module V1
    class MdlistController < BaseController
      before_action :require_token

      VALID_STATUSES = %w[reading on_hold dropped plan_to_read completed re_reading].freeze

      def set_status
        status = params[:status].presence  # nil removes status
        if status && !VALID_STATUSES.include?(status)
          return render json: { error: "Invalid status. Use: #{VALID_STATUSES.join(', ')}" }, status: :unprocessable_entity
        end

        result = MangadexService.set_reading_status(params[:manga_id], status, @token)
        render json: result
      end

      def get_status
        result = MangadexService.reading_status(params[:manga_id], @token)
        render json: result
      end

      def follow
        result = MangadexService.follow_manga(params[:manga_id], @token)
        render json: result
      end

      def unfollow
        result = MangadexService.unfollow_manga(params[:manga_id], @token)
        render json: result
      end

      def index
        result = MangadexService.get_lists(@token)
        render json: result
      end

      def create
        result = MangadexService.create_list(
          params.require(:name),
          params.fetch(:visibility, "private"),
          Array(params[:manga]),
          token: @token
        )
        render json: result, status: :created
      end

      def update
        result = MangadexService.update_list(
          params[:id],
          Array(params.require(:manga)),
          params.require(:version).to_i,
          @token
        )
        render json: result
      end

      private

      def require_token
        @token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        render json: { error: "Authorization token required" }, status: :unauthorized if @token.blank?
      end
    end
  end
end
