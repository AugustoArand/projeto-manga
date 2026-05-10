module Api
  module V1
    class ChaptersController < BaseController
      def show
        @manga   = Manga.find(params[:manga_id])
        @chapter = @manga.chapters.find(params[:id])
        @pages   = @chapter.pages
        @next    = @chapter.next_chapter
        @prev    = @chapter.prev_chapter
      end
    end
  end
end
