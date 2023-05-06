# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "khedut_mall"
set :repo_url, "git@github.com:DavaraTagline/khedutmall-rails.git"
set :deploy_via, :remote_cache

set :rvm_roles, [:app, :web]
set :rbenv_type, :user
set :rbenv_ruby, '3.0.4'

# Default branch is :master
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/root/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, ".env"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage", ".bundle", "node_modules"

# Default value for default_env is {}
set :rails_env, 'production'

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 1

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/khedut-mall.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :default_env, {
  "PATH" => "~/.nvm/versions/node/v16.9.1/bin/:$PATH"
}
# set :assets_roles, %i[webpack] # Give the webpack role to a single server
# set :assets_prefix, 'packs'

before "deploy:assets:precompile", "deploy:yarn_install"


namespace :deploy do
  desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end

after "deploy:log_revision", "puma:restart_server"
namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  desc 'Restart puma server'
  task :restart_server do
    on roles(:app) do
      execute "systemctl restart khedut_mall_puma_production.service"
    end
  end

  before :start, :make_dirs
end
