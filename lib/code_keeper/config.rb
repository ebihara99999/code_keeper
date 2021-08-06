# frozen_string_literal: true

module CodeKeeper
  # Provide configuration
  class Config
    attr_accessor :metrics

    def initialize
      @metrics = [:cyclomatic_complexity]
    end
  end
end
