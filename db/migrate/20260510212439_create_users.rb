class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string  :email,           null: false
      t.string  :username,        null: false
      t.string  :password_digest, null: false
      t.string  :name,            null: false
      t.boolean :vip,             default: false, null: false
      t.integer :level,           default: 1,     null: false
      t.integer :xp,              default: 0,     null: false
      t.string  :avatar_color,    default: "#E8186D"

      t.timestamps
    end

    add_index :users, :email,    unique: true
    add_index :users, :username, unique: true
  end
end
