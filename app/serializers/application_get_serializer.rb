class ApplicationGetSerializer < ActiveModel::Serializer
  attributes :token, :name, :chats_count
end
