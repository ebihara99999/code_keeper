# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::AbcMetric do
  describe "#score" do
    it "returns a hash of a filename and a score, 3.7417, which is the four decimal point" do
      expected_hash = { 'spec/fixtures/branch_in_loop.rb': 3.7417 }
      abc_metric = CodeKeeper::Metrics::AbcMetric.new('spec/fixtures/branch_in_loop.rb')
      expect(abc_metric.score).to eq expected_hash
    end
  end
end
