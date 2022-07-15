require 'application_record'

class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat
  validates_presence_of :body
  validates :number, uniqueness: { scope: :chat_id }

  after_commit on: [:create] do
    __elasticsearch__.index_document if self.body?
  end

  after_commit on: [:update] do
    if self.body?
      __elasticsearch__.update_document
    else
      __elasticsearch__.delete_document
    end
  end

  after_commit on: [:destroy] do
    __elasticsearch__.delete_document if self.body?
  end

  index_name self.name.downcase

  settings analysis: {
    analyzer: {
      comment_analyzer: {
        tokenizer: "standard",
        filter: %w[lowercase comment_edge_ngram_filter]
      }
    },
    filter: {
      comment_edge_ngram_filter: {
        type: "edge_ngram",
        min_gram: 3,
        max_gram: 10
      }
    }
  } do
    mapping dynamic: 'false' do
      indexes :body, type: 'text', analyzer: 'comment_analyzer'
      indexes "chat.id", type: 'keyword'
    end
  end

  def as_indexed_json(options = {})
    self.as_json(include: { chat: { include: { application: { only: [:token, :name] } }, only: [:id, :number] } }, only: [:body, :number])
  end

  def self.search(message_partial_data, chat_id, from = 0, size = 10)
    __elasticsearch__.search(
      {
        from: from,
        size: size,
        query: {
          bool: {
            must:
              {
                match: {
                  body: message_partial_data
                }
              },
            filter: {
              term: {
                "chat.id": chat_id
              }
            }
          }
        }
      })
  end

end
