class VkWrapper

  def self.vk_api(access_token, method, params)
    uri = Addressable::URI.new
    required_params = {
      :access_token => access_token,
      :v=>'5.80'
    }

    params = required_params.merge(params)
    uri.query_values = params
    query = uri.query
    url = format('https://api.vk.com/method/%s?%s', method, query)
    HTTParty.get(url)
  end
end
