module RequestSpecHelper

  def json
    JSON.parse(response.body)
  end

  def json_content_type_header
    {
      "Content-Type" => "application/json"
    }
  end
end