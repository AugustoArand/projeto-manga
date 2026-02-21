class Manga < ApplicationRecord
  has_many :chapters, dependent: :destroy

  GENRES = %w[Ação Aventura Comédia Drama Fantasia Horror Romance Sci-Fi Slice-of-Life Suspense].freeze
  STATUSES = %w[Em\ andamento Completo Hiatus].freeze

  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :search, ->(query) { where("title LIKE ? OR author LIKE ?", "%#{query}%", "%#{query}%") if query.present? }

  def last_chapter
    chapters.order(number: :desc).first
  end

  def latest_chapters
    chapters.order(published_at: :desc).limit(5)
  end
end
