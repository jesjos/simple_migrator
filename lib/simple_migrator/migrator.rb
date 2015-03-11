module SimpleMigrator
  class Migrator
    def initialize(connection, migration_table_name = nil)
      @table_name = migration_table_name
      @connection = connection
      ensure_migration_table!
    end

    def migrate(name, &block)
      connection.transaction do
        unless migrated?(name)
          execute(block)
          was_migrated(name)
        end
      end
    end

    def migrated? migration_name
      migrations_table.where(migration_name: migration_name).any?
    end

    def migrations_table
      connection[table_name]
    end

    def self.default_table_name
      :simple_migrator_schema_migrations
    end

    def table_name
      @table_name || self.class.default_table_name
    end

    private

    def execute(migration)
      migration.call(connection)
    end

    attr_reader :connection

    def ensure_migration_table!
      connection.create_table?(table_name) do
        primary_key :id
        String :migration_name, null: false
        index [:migration_name], unique: true
        DateTime :timestamp, null: false
      end
    end

    def was_migrated(migration_name)
      migrations_table.insert(timestamp: Time.now.utc, migration_name: migration_name)
    end
  end
end