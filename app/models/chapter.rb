class Chapter < ApplicationRecord
  belongs_to :manga
  has_many :pages, dependent: :destroy

  default_scope { order(number: :asc) }

  def next_chapter
    manga.chapters.where("number > ?", number).first
  end

  def prev_chapter
    manga.chapters.where("number < ?", number).last
  end

  def display_number
    number.to_i == number ? number.to_i.to_s : number.to_s
  end
end
