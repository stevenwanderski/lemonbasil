namespace :db do
  desc "Restore latest Heroku db backup locally"
  task restore: :environment do
    restore_local_db_from_heroku("lemonbasil-production")
  end

  def restore_local_db_from_heroku(environment)
    # Get the current db config
    config = Rails.configuration.database_configuration[Rails.env]

    # Get around an issue with the Heroku Toolbelt https://github.com/sstephenson/rbenv/issues/400#issuecomment-18742700
    Bundler.with_clean_env do
      # Download the latest backup to a file called latest.dump in tmp folder
      return if !system("curl -o tmp/latest.dump --progress-bar `heroku pg:backups public-url --app #{environment}`")

      # restoring over an existing db won't remove
      # new migrated columns, which can lead to fun errors
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke

      # Restore the backup to the current database
      system("export PGPASSWORD=#{config["password"]} && /Applications/Postgres.app/Contents/Versions/latest/bin/pg_restore --verbose  --clean  --no-acl --no-owner --host=#{config["host"]} --port=#{config["port"]} --username=#{config["username"]} --dbname=#{config["database"]} tmp/latest.dump")
    end
  end
end
