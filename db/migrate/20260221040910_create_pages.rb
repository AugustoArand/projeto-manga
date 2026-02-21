class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :number
      t.string :image_url

      t.timestamps
    end
  end
end
