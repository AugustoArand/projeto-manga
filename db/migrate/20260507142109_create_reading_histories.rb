class CreateReadingHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_histories do |t|
      t.string :mangadex_id
      t.string :title
      t.string :cover_url
      t.string :genre
      t.references :manga, null: true, foreign_key: true

      t.timestamps
    end
  end
end
