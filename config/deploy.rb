# config valid for current version and patch releases of Capistrano
lock '~> 3.17'

set :application, 'ozoneb_api'
set :repo_url, 'git@github.com:enrique-gonzalez-dev/ozoneb_api.git'

# Default deploy_to directory on the server
set :deploy_to, '/var/www/ozoneb_api'

# Allow overriding branch with ENV['BRANCH']
set :branch, ENV.fetch('BRANCH', 'main')

set :format, :airbrussh
set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

set :pty, true

# Keep 5 releases
set :keep_releases, 5

# rbenv settings — change RBENV_RUBY env var if you use a different version
set :rbenv_type, :user
set :rbenv_ruby, ENV.fetch('RBENV_RUBY', '3.4.1')

# Linked files & dirs (shared between releases)
append :linked_files, 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'storage', 'vendor/bundle'

# If you need to run migrations automatically on deploy
set :migration_role, 'db'
set :conditionally_migrate, true

# Skip assets compilation (API only, no assets)
Rake::Task['deploy:assets:precompile'].clear_actions
Rake::Task['deploy:assets:backup_manifest'].clear_actions

# Default value for :format is :airbrussh.
namespace :deploy do
  after :finishing, 'deploy:cleanup'
end
