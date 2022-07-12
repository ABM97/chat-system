class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat
  validates_presence_of :body
  validates :number, uniqueness: true

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
      indexes :message_body, type: 'text', analyzer: 'comment_analyzer'
      indexes :chat_number, type: 'keyword'
    end
  end

  def as_indexed_json(options = {})
    {
      message_body: self.body,
      message_number: self.number,
      chat_number: chat.number,
      application_name: chat.application.name,
      application_token: chat.application.token,
    }.as_json
  end

  def self.search(message_partial_data, chat_number, from = 0, size = 10)
    __elasticsearch__.search(
      {
        from: from,
        size: size,
        query: {
          bool: {
            must:
              {
                term: {
                  message_body: message_partial_data
                }
              },
            filter: {
              term: {
                chat_number: chat_number
              }
            }
          }
        }
      })
  end

end
