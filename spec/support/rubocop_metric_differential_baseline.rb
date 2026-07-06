# frozen_string_literal: true

require "yaml"

module RuboCopMetricDifferential
  # Loads and validates accepted differences for the RuboCop differential.
  module Baseline
    REQUIRED_KEYS = %w[metric path line side reason].freeze
    SIDES = %w[code_keeper rubocop].freeze

    module_function

    def entries
      YAML.safe_load_file(BASELINE_PATH).fetch("accepted_differences")
    end

    def identities
      entries.map { |entry| identity(entry) }
    end

    def validate_entries
      entries.filter_map do |entry|
        missing = missing_keys(entry)
        invalid = entry_errors(entry)
        next if missing.empty? && invalid.empty?

        entry.merge("missing_keys" => missing, "invalid_values" => invalid)
      end
    end

    def identity(entry)
      {
        "metric" => entry.fetch("metric"),
        "path" => entry.fetch("path"),
        "line" => entry.fetch("line"),
        "side" => entry.fetch("side")
      }
    end

    def missing_keys(entry)
      REQUIRED_KEYS.reject { |key| entry.key?(key) }
    end

    def entry_errors(entry)
      [
        metric_error(entry),
        path_error(entry),
        line_error(entry),
        side_error(entry),
        reason_error(entry)
      ].compact
    end

    def metric_error(entry)
      "metric" unless CodeKeeper::Metrics::MAPPINGS.key?(entry["metric"]&.to_sym)
    end

    def path_error(entry)
      "path" unless entry["path"].is_a?(String) && entry["path"].start_with?(CorpusReportRunner::ROOT)
    end

    def line_error(entry)
      "line" unless entry["line"].is_a?(Integer) && entry["line"].positive?
    end

    def side_error(entry)
      "side" unless SIDES.include?(entry["side"])
    end

    def reason_error(entry)
      "reason" unless entry["reason"].is_a?(String) && !entry["reason"].empty?
    end
  end
end
