class MangasController < ApplicationController
  def index
    @mangas = Manga.all
    @mangas = @mangas.by_genre(params[:genre]) if params[:genre].present?
    @mangas = @mangas.search(params[:query]) if params[:query].present?
    @genres = Manga::GENRES
  end

  def show
    @manga = Manga.find(params[:id])
    @chapters = @manga.chapters.order(number: :desc)
  end
end
