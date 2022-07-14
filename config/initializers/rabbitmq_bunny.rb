$rmq = Bunny.new(host: Rails.configuration.rabbitMQ_host, port: Rails.configuration.rabbitMQ_port)

$rmq.start