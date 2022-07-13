require 'rabbitmq_base_service'

class RabbitmqProducer

  attr_accessor :new_connection, :channel

  def initialize
    @new_connection = RabbitmqBaseService.new
    @new_connection.start
    @channel = @new_connection.create_channel
    puts "Publisher Channel Created"
  end

  def declare_queue(queue_name = "default", durable = true)
    puts "A queue with name #{queue_name} declared"
    @channel.queue(queue_name, durable: durable)
  end

  def publish_message(routing_key, msg, persistent = true)
    puts " Message sent #{msg}"
    @channel.confirm_select
    @channel.default_exchange.publish(msg, routing_key: routing_key, persistent: persistent)
    success = @channel.wait_for_confirms
    unless success
      raise StandardError.new(message: 'Failed to publish job')
    end
  end

  def close_connection
    puts "Connections Closed"
    @new_connection.close
  end

end