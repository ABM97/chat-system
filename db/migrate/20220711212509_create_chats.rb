class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.bigint :number, null: false
      t.bigint :messages_count, null: false, default: 0
      t.bigint :app_id, null: false
      t.timestamps
    end
    add_foreign_key :chats, :applications, column: :app_id, name: :chat_to_application_fk
    add_index(:chats, :app_id, name: :app_id_idx)
  end
end