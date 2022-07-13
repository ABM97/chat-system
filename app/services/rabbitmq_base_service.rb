require 'bunny'

class RabbitmqBaseService

  attr_accessor :connection, :channel

  def initialize
    @connection = Bunny.new(host: Rails.configuration.rabbitMQ_host, port: Rails.configuration.rabbitMQ_port)
  end

  def start
    @connection.start
  end

  def close
    @connection.close
  end

  def create_channel
    @channel = @connection.create_channel
  end

end