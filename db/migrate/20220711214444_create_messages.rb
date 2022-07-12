class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.bigint :number, null: false
      t.bigint :chat_id, null: false
    end
    add_foreign_key :messages, :chats, column: :chat_id, name: :message_to_chat_fk
    add_index(:messages, :chat_id, name: :chat_id_idx)
    add_index(:messages, :number, name: :number_idx, unique: true)
  end
end
