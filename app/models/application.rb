class Application < ApplicationRecord
  include ULID::Rails
  ulid :token, auto_generate: true
  has_many :chats, dependent: :destroy
  validates_presence_of :name
end
