# frozen_string_literal: true

# evil hack to get db-pools when using an environment like heroku that only provides DATABASE_URL
# https://devcenter.heroku.com/articles/concurrency-and-database-connections
# deprecated and should no longer be used ... need to replace this with a nice solution for heroku,
# for now just showing warnings
if !ENV['PRECOMPILE'] &&
  (ENV['DB_POOL'] && Rails.application.config.database_configuration[Rails.env]['pool'] != ENV['DB_POOL'].to_i)

  warn <<-WARN.strip_heredoc
    Currently using an evil ActiveRecord patch that will be removed soon.
    Use a database.yml that uses ENV['DB_POOL'] instead
    https://devcenter.heroku.com/articles/concurrency-and-database-connections
    From: config/initializers/db_pool_from_env.rb
  WARN

  Rails.application.config.after_initialize do
    ActiveRecord::Base.connection_pool.disconnect!

    ActiveSupport.on_load(:active_record) do
      config = Rails.application.config.database_configuration[Rails.env]

      if config
        config['pool'] = (ENV['DB_POOL'] || 100).to_i
        ActiveRecord::Base.establish_connection(config)
      end
    end
  end
end
