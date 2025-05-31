# config/initializers/oas_rails.rb
OasRails.configure do |config|
  # Basic Information about the API
  config.info.title = 'Desafio RdStation - Carrinho de Compras'
  config.info.version = '1.0.0'
  config.info.summary = 'Docs para o desafio de desenvolvimento de uma API Rest para gerenciamento de carrinho de compras'
  config.info.description = <<~HEREDOC
    O desafio consiste em uma API para gerenciamento de um carrinho de compras de e-commerce.
    Você deve desenvolver utilizando a linguagem Ruby e framework Rails, uma API Rest
    que terá 3 endpoints que deverão implementar algumas funcionalidades
  HEREDOC
  config.info.contact.name = 'J-Costa'
  config.info.contact.url = 'https://github.com/J-Costa/rd-challenge'

  # Servers Information. For more details follow: https://spec.openapis.org/oas/latest.html#server-object
  config.servers = [{ url: 'http://localhost:3000', description: 'Local' }]

  # Tag Information. For more details follow: https://spec.openapis.org/oas/latest.html#tag-object
  # config.tags = [{ name: "Users", description: "Manage the `amazing` Users table." }]

  # Optional Settings (Uncomment to use)
  config.include_mode = :with_tags

  # Extract default tags of operations from namespace or controller. Can be set to :namespace or :controller
  # config.default_tags_from = :namespace

  # Automatically detect request bodies for create/update methods
  # Default: true
  # config.autodiscover_request_body = false

  # Automatically detect responses from controller renders
  # Default: true
  # config.autodiscover_responses = false

  # API path configuration if your API is under a different namespace
  # config.api_path = "/"

  # Apply your custom layout. Should be the name of your layout file
  # Example: "application" if file named application.html.erb
  # Default: false
  # config.layout = "application"

  # Excluding custom controllers or controllers#action
  # Example: ["projects", "users#new"]
  # config.ignored_actions = []

  # #######################
  # Authentication Settings
  # #######################

  # Whether to authenticate all routes by default
  # Default is true; set to false if you don't want all routes to include security schemas by default
  config.authenticate_all_routes_by_default = false

  # Default security schema used for authentication
  # Choose a predefined security schema
  # [:api_key_cookie, :api_key_header, :api_key_query, :basic, :bearer, :bearer_jwt, :mutual_tls]
  # config.security_schema = :bearer

  # Custom security schemas
  # You can uncomment and modify to use custom security schemas
  # Please follow the documentation: https://spec.openapis.org/oas/latest.html#security-scheme-object
  #
  # config.security_schemas = {
  #  bearer:{
  #   "type": "apiKey",
  #   "name": "api_key",
  #   "in": "header"
  #  }
  # }

  # ###########################
  # Default Responses (Errors)
  # ###########################

  # The default responses errors are set only if the action allow it.
  # Example, if you add forbidden then it will be added only if the endpoint requires authentication.
  # Example: not_found will be setted to the endpoint only if the operation is a show/update/destroy action.
  # config.set_default_responses = true
  # config.possible_default_responses = [:not_found, :unauthorized, :forbidden, :internal_server_error, :unprocessable_entity]
  # config.response_body_of_default = "Hash{ message: String }"
  # config.response_body_of_unprocessable_entity= "Hash{ errors: Array<String> }"
end
