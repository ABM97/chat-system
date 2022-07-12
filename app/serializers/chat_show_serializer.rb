class ChatShowSerializer < ActiveModel::Serializer
  attributes :number, :messages

  def messages
    object.messages.map do |message|
      MessageSerializer.new(message, scope: scope, root: false, event: object)
    end
  end
end
