module SimpleMigrator
  class Migration
    attr_reader :proc, :name

    def initialize(name, proc)
      @name = name
      @proc = proc
    end

    def <=>(other)
      self.name <=> other.name
    end
  end
end