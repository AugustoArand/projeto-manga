class ReadingHistory < ApplicationRecord
  belongs_to :manga, optional: true

  validates :title, presence: true

  scope :recent, -> { order(updated_at: :desc).limit(20) }
  scope :unique_titles, -> { select("DISTINCT ON (COALESCE(mangadex_id, CAST(manga_id AS TEXT))) *").order("COALESCE(mangadex_id, CAST(manga_id AS TEXT)), updated_at DESC") }

  # Registrar acesso a um mangá (local ou da API)
  def self.track(attrs)
    record = if attrs[:mangadex_id].present?
               find_or_initialize_by(mangadex_id: attrs[:mangadex_id])
             elsif attrs[:manga_id].present?
               find_or_initialize_by(manga_id: attrs[:manga_id])
             else
               new
             end

    record.assign_attributes(attrs)
    record.save!
    record
  end

  # Gêneros mais consumidos pelo usuário
  def self.top_genres(limit = 5)
    where.not(genre: [nil, ""])
         .group(:genre)
         .order("count_all DESC")
         .limit(limit)
         .count
         .keys
  end
end
