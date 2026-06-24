# frozen_string_literal: true

module CodeKeeper
  # Store results of each score.
  class Result
    attr_reader :scores, :snapshot

    def initialize
      @scores = CodeKeeper.config.metrics.map { |key| [key, {}] }.to_h
      @snapshot = Snapshot.new
    end

    def add(metric, klass_or_path, score)
      scores[:"#{metric}"].store(klass_or_path, score)
    end

    def add_measurement(measurement)
      snapshot.add(measurement)
      add(measurement.metric, measurement.legacy_key, measurement.value)
    end
  end
end
