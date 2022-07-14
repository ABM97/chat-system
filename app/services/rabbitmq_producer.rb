class RabbitmqProducer

  attr_accessor :channel

  def self.publish(queue_name, object)
    publisher = RabbitmqProducer.new
    queue = publisher.send(:declare_queue, queue_name)
    publisher.send(:publish_message, queue.name, object.to_json)
  end

  private

  def initialize
    @channel = $rmq.create_channel
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
      @channel.close
      raise StandardError.new(message: 'Failed to publish job')
    end
    @channel.close
  end

end