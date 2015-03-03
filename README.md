# SimpleMigrator

`SimpleMigrator` serves a simple purpose:

- Use the [Sequel gem](https://github.com/jeremyevans/sequel) to access database
- Keep track of database schema migrations
- Do so without having to put migration files in a specific folders
- Run migrations in order, sorted by migration name

It has some important caveats:

- The programmer is responsible for choosing a unique name for migrations
- There's no way of controlling order other than using migration names

`SimpleMigrator` contains a module `Migratable` which can be used to define migrations using a simple DSL.

## Usage

### Just migrate stuff

    db = Sequel.sqlite
    migrator = SimpleMigrator.migrator(db)
    migrator.migrate("my_migration") do |connection|
      # do stuff
    end
    # Your stuff has been done
    migrator.migrate("my_migration") do
      # This time the migrator won't execute the block
    end

### Using Migratable

    class Foo
      include SimpleMigrator::Migratable

      migration "20150303-1" do |db|
        create_my_table(db)
        create_my_other_table(db)
      end

      migration "20150303-2" do |db|
        add_column(db)
      end

      def create_my_table(db)
      end

      def create_my_other_table(db)
      end

      def add_column(db)
      end
    end

    db = Sequel.sqlite
    
    migrator = SimpleMigrator.migrator(db)

    foo = Foo.new

    foo.migrate(migrator)

