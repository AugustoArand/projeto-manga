module Api
  module V1
    class ReadingHistoriesController < BaseController
      def index
        @histories = ReadingHistory.recent
        render json: @histories.map { |h|
          {
            id: h.id,
            title: h.title,
            cover_url: h.cover_url,
            genre: h.genre,
            manga_id: h.manga_id,
            mangadex_id: h.mangadex_id,
            updated_at: h.updated_at
          }
        }
      end

      def create
        @history = ReadingHistory.track(history_params)
        render json: { id: @history.id }, status: :created
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def history_params
        params.require(:reading_history).permit(
          :manga_id, :mangadex_id, :title, :cover_url, :genre
        )
      end
    end
  end
end
