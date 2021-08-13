# frozen_string_literal: true

module CodeKeeper
  # Store results of each score.
  class Result
    attr_reader :scores

    def initialize
      @scores = CodeKeeper.config.metrics.map { |key| [key, {}] }.to_h
    end

    def add(metric, path, score)
      scores[:"#{metric}"].store(path, score)
    end
  end
end
