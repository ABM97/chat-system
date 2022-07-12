class ElasticSearchMessageIndexSerializer

  def self.map(message)
    {
      message_body: message._source.message_body,
      message_number: message._source.message_number,
      chat_number: message._source.chat_number,
      application_name: message._source.application_name,
      application_token: message._source.application_token
    }
  end

end
