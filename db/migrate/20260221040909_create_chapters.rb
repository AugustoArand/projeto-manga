class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.references :manga, null: false, foreign_key: true
      t.float :number
      t.string :title
      t.datetime :published_at

      t.timestamps
    end
  end
end
