require "sequel"

require "simple_migrator/version"
require "simple_migrator/migration"
require "simple_migrator/migrator"
require "simple_migrator/migratable"

module SimpleMigrator
  class << self
    def migrator(*args, &block)
      Migrator.new(*args, &block)
    end
  end
end
