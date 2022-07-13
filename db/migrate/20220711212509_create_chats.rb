class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.bigint :number, null: false
      t.bigint :messages_count, null: false, default: 0
      t.bigint :application_id, null: false
      t.string :check_sum, null: false, limit: 255
    end
    add_foreign_key :chats, :applications, column: :application_id, name: :chat_to_application_fk
    add_index(:chats, :application_id, name: :app_id_idx)
    add_index(:chats, [:number, :application_id], name: :unique_number_per_app_idx, unique: true)
  end
end