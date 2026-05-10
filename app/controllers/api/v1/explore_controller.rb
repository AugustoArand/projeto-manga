module Api
  module V1
    class ExploreController < BaseController
      def index
        @popular = MangadexService.popular(limit: 10)
        @latest  = MangadexService.latest_chapters(limit: 15)
        @categories = MangadexService.genre_tags
        @history = ReadingHistory.recent
        @recommendations = MangadexService.recommendations(limit: 10)
      end

      def category
        @tag_name = params[:name] || "Categoria"
        @mangas   = MangadexService.by_tag(params[:tag_id], limit: 24)
      end
    end
  end
end
