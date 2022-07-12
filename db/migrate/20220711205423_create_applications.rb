class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.binary :token, limit: 16, auto_generate: true
      t.string :name, null: false, limit: 255
      t.bigint :chats_count, null: false , default: 0
    end
    add_index(:applications, :token, unique: true, name: :unique_token_idx)
  end
end
