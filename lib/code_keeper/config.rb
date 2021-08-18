# frozen_string_literal: true

module CodeKeeper
  # Provide configuration
  class Config
    attr_accessor :metrics, :number_of_threads

    def initialize
      @metrics = [:cyclomatic_complexity]
      @number_of_threads = 2
    end
  end
end
