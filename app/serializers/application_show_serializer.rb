class ApplicationShowSerializer < ActiveModel::Serializer
  attributes :token, :name, :chats_count, :chats
  def chats
    object.chats.map do |chat|
      ChatSerializer.new(chat, scope: scope, root: false, event: object)
    end
  end
end
