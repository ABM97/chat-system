require 'application_record'

class Application < ApplicationRecord
  include ULID::Rails
  ulid :token, auto_generate: true
  has_many :chats, dependent: :destroy
  validates_presence_of :name
  validates :token, uniqueness: true
end
