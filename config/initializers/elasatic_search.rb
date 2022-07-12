config = {
  host: Rails.configuration.elastic_serach_url
}
Elasticsearch::Model.client = Elasticsearch::Client.new(config)