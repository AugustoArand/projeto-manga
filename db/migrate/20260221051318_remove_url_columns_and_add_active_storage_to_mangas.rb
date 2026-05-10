class RemoveUrlColumnsAndAddActiveStorageToMangas < ActiveRecord::Migration[8.1]
  def change
    # Remove colunas de URL legadas — substituídas por Active Storage
    remove_column :mangas, :cover_url, :string
    remove_column :pages, :image_url, :string
  end
end
