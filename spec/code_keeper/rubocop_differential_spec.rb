# frozen_string_literal: true

require "spec_helper"
require "support/corpus_report_runner"
require "support/rubocop_metric_oracle"
require "support/rubocop_metric_differential"

RSpec.describe "RuboCop metric differential" do
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
