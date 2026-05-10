class Manga < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_one_attached :cover

  GENRES = %w[Ação Aventura Comédia Drama Fantasia Horror Romance Sci-Fi Slice-of-Life Suspense].freeze
  STATUSES = %w[Em\ andamento Completo Hiatus].freeze

  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :search, ->(query) { where("title ILIKE ? OR author ILIKE ?", "%#{query}%", "%#{query}%") if query.present? }

  def last_chapter
    chapters.order(number: :desc).first
  end

  def latest_chapters
    chapters.order(published_at: :desc).limit(5)
  end
end
