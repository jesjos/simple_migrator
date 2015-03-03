require 'spec_helper'

describe SimpleMigrator do
  describe "::migrator" do
    let(:db) { Sequel.sqlite }
    it "returns a migrator" do
      expect(SimpleMigrator.migrator(db)).to be_a(SimpleMigrator::Migrator)
    end
  end
end
