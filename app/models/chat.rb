require 'application_record'

class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages, dependent: :destroy
  validates_presence_of :application_id
  validates :number, uniqueness: { scope: :application_id }
end
