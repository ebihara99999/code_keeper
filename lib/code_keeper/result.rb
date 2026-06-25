# frozen_string_literal: true

module CodeKeeper
  # Store results of each score.
  class Result
    attr_reader :scores, :metric_report

    def initialize
      @scores = CodeKeeper.config.metrics.map { |key| [key, {}] }.to_h
      @metric_report = MetricReport.new
    end

    def add(metric, klass_or_path, score)
      scores[:"#{metric}"].store(klass_or_path, score)
    end

    def add_measurement(measurement)
      metric_report.add(measurement)
      add(measurement.metric, measurement.score_key, measurement.value)
    end
  end
end
