# frozen_string_literal: true

module RuboCopMetricDifferential
  # A measurement present on only one side of the differential.
  Difference = Struct.new(:metric, :path, :line, :side, :value, keyword_init: true) do
    def identity
      {
        "metric" => metric.to_s,
        "path" => path,
        "line" => line,
        "side" => side.to_s
      }
    end

    def to_h
      identity.merge("value" => value)
    end
  end

  # A non-unique path/line key on one side of the differential.
  DuplicateKey = Struct.new(:metric, :path, :line, :side, :measurement_values, keyword_init: true) do
    def to_h
      {
        "metric" => metric.to_s,
        "path" => path,
        "line" => line,
        "side" => side.to_s,
        "values" => measurement_values
      }
    end
  end

  # A measurement key present on both sides with different metric values.
  ValueMismatch = Struct.new(:metric, :path, :line, :code_keeper_value, :rubocop_value, keyword_init: true) do
    def to_h
      {
        "metric" => metric.to_s,
        "path" => path,
        "line" => line,
        "code_keeper_value" => code_keeper_value,
        "rubocop_value" => rubocop_value
      }
    end
  end

  # Mutable state used while comparing one corpus run.
  ComparisonState = Struct.new(:differences, :duplicate_keys, :value_mismatches, keyword_init: true)

  # Final differential result consumed by specs.
  Result = Struct.new(:unexpected_differences, :stale_baseline_entries, :duplicate_keys, :value_mismatches, keyword_init: true)
end
