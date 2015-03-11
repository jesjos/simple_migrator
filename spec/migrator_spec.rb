require 'spec_helper'

module SimpleMigrator
  describe Migrator do
    let(:connection) { Sequel.sqlite }
    let(:migrator) { Migrator.new(connection) }

    describe "#initialize" do
      context "when no prior migration table exists" do
        context "when given no explicit table name" do
          before do
            Migrator.new(connection)
          end

          it "creates one" do
            expect(connection.tables).to include(Migrator.default_table_name)
          end
        end

        context "when given an explicit table name" do
          context "when given a table name" do
            let(:table_name) { :foobar }
            before do
              Migrator.new(connection, table_name)
            end
            it "creates a table with that name" do
              expect(connection.tables).to include(table_name)
            end
          end
        end
      end
    end

    describe "#migrated?" do
      context "when a migration of that name has been migrated" do
        it "returns true" do
          migrator.migrate("foo", & -> (_db) {})
          expect(migrator.migrated?("foo")).to be_truthy
        end
      end

      context "when the migration has not been run" do
        it "returns true" do
          expect(migrator.migrated?("foo")).to be_falsey
        end
      end
    end

    describe "#migrate" do
      context "when the migration has not been run previously" do
        it "runs the migration" do
          expect { |b| migrator.migrate("foo", &b) }.to yield_control
        end

        it "writes the migration name to the migrations table" do
          migration = -> (_) {}
          migrator.migrate("foo", &migration)
          migrations = migrator.migrations_table.select_map(:migration_name)
          expect(migrations).to include("foo")
        end
      end

      context "when the migration has already run" do
        it "does not re run it" do
          migrator.migrate("foo", & ->(_) {})
          expect { |b| migrator.migrate("foo", &b) }.to_not yield_control
        end
      end
    end
  end
end