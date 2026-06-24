# frozen_string_literal: true

module CodeKeeper
  # Stores metric-native measurements and derives a compact review summary.
  class Snapshot
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
          top_hotspots: group.select { |measurement| measurement.value == max_value }.map(&:to_h)
        }
      end
    end
  end
end
