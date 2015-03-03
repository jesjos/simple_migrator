module SimpleMigrator
  module Migratable
    def migrate!(migrator = migrator)
      self.class.migrations.each do |migration|
        rebound_proc = rebind_proc(migration.proc)
        name = prefixed_migration_name(migration.name)
        migrator.migrate(name, &rebound_proc)
      end
    end

    def prefixed_migration_name(name)
      if migration_prefix
        [migration_prefix, name].join("_")
      else
        name
      end
    end

    def migration_prefix; end

    def migrator
      raise NoMigratorError, "`migrate!` called without a migrator.\nEither provide a migrator or define a `migrator` method"
    end

    def rebind_proc(proc)5
      Proc.new do |db|
        instance_exec(db, &proc)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def migration(name, &block)
        migrations.add(Migration.new(name, block))
      end

      def migrations
        @migrations ||= SortedSet.new
      end
    end
  end
end