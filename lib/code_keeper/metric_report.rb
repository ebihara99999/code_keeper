# frozen_string_literal: true

module CodeKeeper
  # Stores metric-native measurements and derives a compact review summary.
  class MetricReport
    TOP_HOTSPOTS_LIMIT = 5

    attr_reader :measurements

    def initialize(measurements = [])
      @measurements = measurements
    end

    def add(measurement)
      measurements << measurement
    end

    def to_h
      {
        summary: {
          metrics: summary_by_metric
        },
        measurements: measurements.map(&:to_h)
      }
    end

    private

    def summary_by_metric
      measurements.group_by(&:metric).transform_values do |group|
        max_value = group.map(&:value).max

        {
          count: group.size,
          max: max_value,
          top_hotspots: top_hotspots(group)
        }
      end
    end

    def top_hotspots(measurements)
      measurements
        .sort_by { |measurement| [-measurement.value, measurement.path, measurement.start_line, measurement.scope_name] }
        .first(TOP_HOTSPOTS_LIMIT)
        .map(&:to_h)
    end
  end
end
