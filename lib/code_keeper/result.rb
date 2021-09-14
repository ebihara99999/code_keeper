# frozen_string_literal: true

module CodeKeeper
  # Store results of each score.
  class Result
    attr_reader :scores

    def initialize
      @scores = CodeKeeper.config.metrics.map { |key| [key, {}] }.to_h
    end

    def add(metric, klass_or_path, score)
      scores[:"#{metric}"].store(klass_or_path, score)
    end
  end
end
