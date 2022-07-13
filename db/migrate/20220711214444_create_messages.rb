class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.bigint :number, null: false
      t.bigint :chat_id, null: false
      t.string :check_sum, null: false, limit: 255
    end
    add_foreign_key :messages, :chats, column: :chat_id, name: :message_to_chat_fk
    add_index(:messages, :chat_id, name: :chat_id_idx)
    add_index(:messages, [:number, :chat_id], name: :unique_number_per_chat_idx, unique: true)
  end
end
