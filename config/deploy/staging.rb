# staging server configuration
set :stage, :staging
set :rails_env, 'production'

# Environment variables for the app
set :default_env, {
  'RAILS_ENV' => 'production',
  'OZONEB_API_DATABASE_PASSWORD' => 'OzoneBenefits2025',
  'RAILS_SERVE_STATIC_FILES' => 'true',
  'RAILS_LOG_TO_STDOUT' => 'true',
  'RAILS_MAX_THREADS' => '5'
}

# Replace with your server IP and user
server '18.119.132.48', user: 'ubuntu', roles: %w{app db web}, ssh_options: {
  user: 'ubuntu',
  keys: %w(~/.ssh/grupo-ozone-benefits-api.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}

# Branch to deploy for staging (can be overridden with ENV['BRANCH'])
set :branch, ENV.fetch('BRANCH', 'main')
