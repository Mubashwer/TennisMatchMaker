OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '945971337527-9mnbpnk848okmn7ppjcch17ol3o8kppt.apps.googleusercontent.com', 'OrbPFoQqY4e0dnLTH4kRK7dN', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end