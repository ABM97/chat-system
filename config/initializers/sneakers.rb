require 'sneakers'

module Connection
  def self.sneakers
    @_sneakers ||= Bunny.new(host: Rails.configuration.rabbitMQ_host, port: Rails.configuration.rabbitMQ_port)
  end
end

Sneakers.configure connection: Connection.sneakers,
                   log: STDOUT,
                   durable: true,
                   threads: 10,
                   ack: true

Sneakers.logger.level = Logger::INFO