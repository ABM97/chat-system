require 'chat'
require 'message'

module RedisService

  def self.get_current_counter_value(object_name)
    $redis.with do |connection|
      connection.multi do |multi|
        multi.hset(object_name, :timestamp, Time.now.to_i)
        multi.hincrby(object_name, :number, 1)
      end[1]
    end
  end

  def self.sync_counter_data(prefix, model, count_field)
    $redis.with do |connection|
      connection.scan_each(:match => "#{prefix}_*") do |key|
        object = {}
        connection.hscan_each(key) do |field, value|
          object[field] = value
        end
        minutes_diff = ((Time.now.to_i - object["timestamp"].to_i) / 60.0).round
        if minutes_diff <= 60
          model.where(id: key.split('_')[1]).update(count_field.to_s => object["number"])
        elsif minutes_diff <= 120
          connection.hdel(key)
        end
      end
    end
  end

end
