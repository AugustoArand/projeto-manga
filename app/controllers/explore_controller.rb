class ExploreController < ApplicationController
  def index
    @popular = MangadexService.popular(limit: 10)
    @latest = MangadexService.latest_chapters(limit: 15)
    @categories = MangadexService.genre_tags
    @history = ReadingHistory.order(updated_at: :desc).limit(12)
    @recommendations = MangadexService.recommendations(limit: 10)

    # Hero: os 5 primeiros populares para o slider
    @hero_mangas = @popular.first(5)
  end

  def category
    @tag_id = params[:tag_id]
    @tag_name = params[:name] || "Categoria"
    @mangas = MangadexService.by_tag(@tag_id, limit: 20)
    @categories = MangadexService.genre_tags
  end
end
