require 'rabbitmq_producer'

class RabbitmqPublisher

  def self.publish(queue_name, object)
    publisher = RabbitmqProducer.new
    queue = publisher.declare_queue(queue_name)
    publisher.publish_message(queue.name, object.to_json)
  end

end