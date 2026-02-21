class ChaptersController < ApplicationController
  def show
    @manga = Manga.find(params[:manga_id])
    @chapter = @manga.chapters.find(params[:id])
    @pages = @chapter.pages
    @next_chapter = @chapter.next_chapter
    @prev_chapter = @chapter.prev_chapter
    @all_chapters = @manga.chapters.order(number: :asc)
  end
end
