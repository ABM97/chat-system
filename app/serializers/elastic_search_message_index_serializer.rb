class ElasticSearchMessageIndexSerializer

  def self.map(message)
    {
      message_body: message._source.body,
      message_number: message._source.number,
      chat_number: message._source.chat.number,
      application_name: message._source.chat.application.name,
      application_token: message._source.chat.application.token
    }
  end

end
