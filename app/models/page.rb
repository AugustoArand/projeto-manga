class Page < ApplicationRecord
  belongs_to :chapter

  default_scope { order(number: :asc) }
end
