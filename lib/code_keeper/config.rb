# frozen_string_literal: true

module CodeKeeper
  # Provide configuration
  class Config
    attr_accessor :metrics, :number_of_threads, :format

    def initialize
      @metrics = %i[cyclomatic_complexity class_length abc_metric]
      @number_of_threads = 2
      @format = :json # json and csv are supported.
    end
  end
end
