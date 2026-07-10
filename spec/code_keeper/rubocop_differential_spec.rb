# frozen_string_literal: true

require "spec_helper"
require "support/corpus_report_runner"
require "support/rubocop_metric_oracle"
require "support/rubocop_metric_differential"

RSpec.describe "RuboCop metric differential" do
  it "keeps wrapper cops out of the global RuboCop registry" do
    expected_cops = {
      "Metrics/AbcSize" => RuboCop::Cop::Metrics::AbcSize,
      "Metrics/CyclomaticComplexity" => RuboCop::Cop::Metrics::CyclomaticComplexity,
      "Metrics/ClassLength" => RuboCop::Cop::Metrics::ClassLength,
      "Metrics/ModuleLength" => RuboCop::Cop::Metrics::ModuleLength
    }
    registered_cops = expected_cops.keys.to_h do |cop_name|
      [cop_name, RuboCop::Cop::Registry.global.find_by_cop_name(cop_name)]
    end

    expect(registered_cops).to eq expected_cops
  end

  it "keeps accepted-difference baseline entries well-formed" do
    expect(RuboCopMetricDifferential.validate_baseline_entries).to eq []
  end

  it "matches RuboCop metric values over the vendored corpus" do
    result = RuboCopMetricDifferential.compare(CorpusReportRunner.file_paths)

    aggregate_failures do
      expect(result.duplicate_keys.map(&:to_h)).to eq []
      expect(result.value_mismatches.map(&:to_h)).to eq []
      expect(result.unexpected_differences.map(&:to_h)).to eq []
      expect(result.stale_baseline_entries).to eq []
    end
  end
end
