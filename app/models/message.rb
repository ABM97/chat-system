class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :body
  validates :number, uniqueness: true
end
