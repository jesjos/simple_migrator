require 'spec_helper'

module SimpleMigrator
  class FakeMigrator

    attr_accessor :driver

    def migrate(_, proc)
      proc.call(driver)
    end

  end

  describe Migratable do

    let(:klass) do
      Class.new do
        include Migratable

        migration("20140923-1") do |db|
          db.do_stuff(my_instance_method)
        end

        migration("20140923-2") do |db|
          db.do_stuff(my_instance_other_method)
        end

        def my_instance_method
          "foo"
        end

        def my_instance_other_method
          "bar"
        end

        def migrator
          @migrator ||= FakeMigrator.new
        end
      end
    end

    describe "::migration" do
      it "adds the migration to the class variable" do
        klass.migration("apa") { "foo" }
        expect(klass.migrations.map(&:name)).to include("apa")
      end
    end

    describe "::migrations" do
      it "returns a sorted collection" do
        migration_names = klass.migrations.map(&:name)
        expect(migration_names).to be_sorted
      end
    end

    describe "#migrate!" do
      it "calls the instance methods" do
        instance = klass.new
        driver = double
        expect(driver).to receive(:do_stuff).twice
        instance.migrator.driver = driver
        expect(instance).to receive(:my_instance_method)
        expect(instance).to receive(:my_instance_other_method)
        instance.migrate!
      end
    end

    describe "#prefixed_migration_name" do
      let(:subject) { klass.new }
      context "when there is a migration_prefixed defined" do
        it "prefixes the input" do
          def subject.migration_prefix
            "foo"
          end
          expect(subject.prefixed_migration_name("bar")).to eq("foo_bar")
        end
      end

      context "when there is no migration prefix" do
        it "returns the input" do
          def subject.migration_prefix
            nil
          end
          expect(subject.prefixed_migration_name("bar")).to eq("bar")
        end
      end
    end
  end
end