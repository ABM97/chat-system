require 'chat'
require 'message'

module RedisService

  def self.decrement_counter_value(object_name)
    $redis.with do |connection|
      connection.multi do |multi|
        multi.hset(object_name, :timestamp, Time.now.to_i)
        multi.hide(object_name, :count, -1)
      end
    end
  end

  def self.increment_and_get_counter_value(object_name)
    $redis.with do |connection|
      connection.multi do |multi|
        multi.hset(object_name, :timestamp, Time.now.to_i)
        multi.hincrby(object_name, :number, 1)
        multi.hincrby(object_name, :count, 1)
      end[1]
    end
  end

  def self.sync_counter_data(prefix, model, count_field)
    batch = []
    batch_size = 50
    $redis.with do |connection|
      connection.scan_each(:match => "#{prefix}_*") do |key|
        object = {}
        connection.hscan_each(key) do |field, value|
          object[field] = value
        end
        minutes_diff = ((Time.now.to_i - object["timestamp"].to_i) / 60.0).round
        if minutes_diff <= 70
          batch << { id: key.split('_')[1].to_i, count_field.to_s => object["count"] }
          if batch.size == batch_size
            execute_batch_update_query(model, count_field, batch)
            batch = []
          end
        elsif minutes_diff >= 120
          hdelall(key, connection)
        end
      end
      unless batch.empty?
        execute_batch_update_query(model, count_field, batch)
        batch = []
      end
    end
  end

  private

  def self.execute_batch_update_query(model, count_field, batch)
    statement = "UPDATE #{model.table_name} SET #{count_field} = CASE" +
      "#{batch.map { |entity| " WHEN id = #{entity[:id]} THEN #{entity[count_field]}" }.join("")} END" +
      " WHERE ID IN (#{batch.map { |entity| entity[:id] }.join(",")})"
    p statement
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def self.hdelall(key, connection)
    keys = connection.hgetall(key).keys
    connection.multi do |multi|
      keys.each do |k|
        multi.hdel key, k
      end
    end
  end

end
