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

    result = HTTParty.get(url)

    ########################################################
    #$required_params = [
    #'access_token' => $access_token,
    #'v' => '5.80'
    #];
  # $params = array_merge($required_params, $params);

  # $url = sprintf("https://api.vk.com/method/%s?%s", $method, http_build_query($params));

  # $result = json_decode(file_get_contents($url));

  # return (isset($result->response)) ? $result->response:$result;

  ######################################################## HTTParty.get('https://api.vk.com/method/photos.getMessagesUploadServer')




  end
end
