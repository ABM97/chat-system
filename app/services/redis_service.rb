require 'chat'
require 'message'

module RedisService

  BATCH_SIZE = 50
  COUNTER_SYNC_THRESHOLD_IN_MINUTE = 40

  def self.increment_and_get_counter_value(object_name)
    $redis.with do |connection|
      connection.multi do |multi|
        multi.hset(object_name, :timestamp, Time.now.to_i)
        multi.hincrby(object_name, :number, 1)
      end[1]
    end
  end

  def self.sync_counter_data(prefix, model, count_field)
    batch = []
    $redis.with do |connection|
      connection.scan_each(:match => "#{prefix}_*") do |key|
        object = {}
        connection.hscan_each(key) do |field, value|
          object[field] = value
        end
        minutes_diff = ((Time.now.to_i - object["timestamp"].to_i) / 60.0).round
        if minutes_diff <= COUNTER_SYNC_THRESHOLD_IN_MINUTE
          batch << { id: key.split('_')[1].to_i, count_field.to_s => object["number"] }
          if batch.size == BATCH_SIZE
            execute_batch_update_query(model, count_field, batch)
            batch = []
          end
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
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(statement)
    end
  end

end
