namespace :deploy do
  desc 'Run seeds on the remote server'
  task :seed do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, 'db:seed'
        end
      end
    end
  end
end
