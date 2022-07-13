require 'chat'
require 'message'

module RedisService

  def self.get_current_counter_value(model, object_name, *sql_params)
    if $redis.hexists(object_name, :count)
      $redis.hset(object_name, :timestamp, Time.now.to_i)
      return $redis.hincrby(object_name, :count, 1)
    else
      max_number = model.where(*sql_params).maximum(:number)
      if $redis.hexists(object_name, :count)
        $redis.hset(object_name, :timestamp, Time.now.to_i)
        return $redis.hincrby(object_name, :count, 1)
      else
        $redis.hset(object_name, :timestamp, Time.now.to_i)
        return $redis.hincrby(object_name, :count, max_number.nil? ? 1 : max_number + 1)
      end
    end
  end

  def self.sync_counter_data(model, hash_table_name)
    $redis.scan_each(:match => "token_*") do |key|
      object = {}
      $redis.hscan_each(key) do |field, value|
        object[field] = value
      end
      minutes_diff = ((Time.now.to_i - object["timestamp"].to_i) / 60.0).round
      if minutes_diff <= 60
        # should be synced
      elsif minutes_diff <= 120
        # should be deleted
        $redis.hdel(key)
      end
    end
  end

end
