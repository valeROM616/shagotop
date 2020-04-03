Rails.application.configure do
  config.rest_server = Rails.application.config_for(:rest_server).with_indifferent_access
end
