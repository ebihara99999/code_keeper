# frozen_string_literal: true

require "support/rubocop_metric_differential_types"
require "support/rubocop_metric_differential_baseline"

# Compares CodeKeeper measurements with raw values captured from RuboCop's cop
# pipeline and applies an explicit accepted-differences baseline.
module RuboCopMetricDifferential
  BASELINE_PATH = "spec/fixtures/rubocop_differential_baseline.yml"

  module_function

  def compare(paths)
    state = ComparisonState.new(differences: [], duplicate_keys: [], value_mismatches: [])

    paths.each do |path|
      code_keeper_measurements = code_keeper_measurements_for(path)
      rubocop_measurements = RuboCopMetricOracle.measurements_for(path)
      compare_measurements(code_keeper_measurements, rubocop_measurements, state)
    end

    Result.new(
      unexpected_differences: unexpected_differences(state.differences),
      stale_baseline_entries: stale_baseline_entries(state.differences),
      duplicate_keys: state.duplicate_keys,
      value_mismatches: state.value_mismatches
    )
  end

  def validate_baseline_entries
    Baseline.validate_entries
  end

  def compare_measurements(code_keeper_measurements, rubocop_measurements, state)
    code_keeper_groups = code_keeper_measurements.group_by { |measurement| measurement_key(measurement) }
    rubocop_groups = rubocop_measurements.group_by { |measurement| measurement_key(measurement) }

    (code_keeper_groups.keys | rubocop_groups.keys).each do |key|
      code_keeper_group = code_keeper_groups.fetch(key, [])
      rubocop_group = rubocop_groups.fetch(key, [])
      compare_group(key, code_keeper_group, rubocop_group, state)
    end
  end

  def compare_group(key, code_keeper_group, rubocop_group, state)
    record_duplicate_key(:code_keeper, key, code_keeper_group, state)
    record_duplicate_key(:rubocop, key, rubocop_group, state)

    if code_keeper_group.empty?
      rubocop_group.each { |measurement| state.differences << difference_from(:rubocop, measurement) }
    elsif rubocop_group.empty?
      code_keeper_group.each { |measurement| state.differences << difference_from(:code_keeper, measurement) }
    elsif code_keeper_group.one? && rubocop_group.one?
      compare_value(code_keeper_group.first, rubocop_group.first, state)
    end
  end

  def compare_value(code_keeper_measurement, rubocop_measurement, state)
    return if code_keeper_measurement.value == rubocop_measurement.value

    state.value_mismatches << ValueMismatch.new(
      metric: code_keeper_measurement.metric,
      path: code_keeper_measurement.path,
      line: code_keeper_measurement.start_line,
      code_keeper_value: code_keeper_measurement.value,
      rubocop_value: rubocop_measurement.value
    )
  end

  def record_duplicate_key(side, key, measurements, state)
    return unless measurements.size > 1

    metric, path, line = key
    state.duplicate_keys << DuplicateKey.new(
      metric: metric,
      path: path,
      line: line,
      side: side,
      measurement_values: measurements.map(&:value)
    )
  end

  def difference_from(side, measurement)
    Difference.new(
      metric: measurement.metric,
      path: measurement.path,
      line: measurement.start_line,
      side: side,
      value: measurement.value
    )
  end

  def unexpected_differences(differences)
    accepted = Baseline.identities

    differences.reject { |difference| accepted.include?(difference.identity) }
  end

  def stale_baseline_entries(differences)
    observed = differences.map(&:identity)

    Baseline.entries.reject { |entry| observed.include?(Baseline.identity(entry)) }
  end

  def code_keeper_measurements_for(path)
    CorpusReportRunner.report_for(path, number_of_threads: 1).measurements
  end

  def measurement_key(measurement)
    [measurement.metric, measurement.path, measurement.start_line]
  end
end
