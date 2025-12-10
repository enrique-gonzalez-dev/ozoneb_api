# staging server configuration
set :stage, :staging
set :rails_env, 'production'

# Replace with your server IP and user
server '18.119.132.48', user: 'ubuntu', roles: %w{app db web}, ssh_options: {
  user: 'ubuntu',
  keys: %w(~/.ssh/grupo-ozone-benefits-api.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}

# Branch to deploy for staging (can be overridden with ENV['BRANCH'])
set :branch, ENV.fetch('BRANCH', 'main')
