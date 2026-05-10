class Page < ApplicationRecord
  belongs_to :chapter

  # Active Storage — imagens hospedadas no Google Cloud Storage
  has_one_attached :image

  default_scope { order(number: :asc) }

  # URL da imagem via Active Storage
  def image_src
    image if image.attached?
  end
end
