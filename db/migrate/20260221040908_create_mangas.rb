class CreateMangas < ActiveRecord::Migration[8.1]
  def change
    create_table :mangas do |t|
      t.string :title
      t.string :author
      t.text :description
      t.string :cover_url
      t.string :genre
      t.string :status
      t.decimal :rating

      t.timestamps
    end
  end
end
