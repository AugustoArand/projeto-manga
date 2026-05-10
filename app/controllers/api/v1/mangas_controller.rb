module Api
  module V1
    class MangasController < BaseController
      def index
        @mangas = Manga.all
        @mangas = @mangas.by_genre(params[:genre]) if params[:genre].present?
        @mangas = @mangas.search(params[:query])   if params[:query].present?
      end

      def show
        @manga    = Manga.find(params[:id])
        @chapters = @manga.chapters.order(number: :desc)
      end
    end
  end
end
