class CreateUserSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string     :token,      null: false
      t.datetime   :expires_at, null: false
      t.string     :device_info

      t.timestamps
    end

    add_index :user_sessions, :token, unique: true
  end
end
