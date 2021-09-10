# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::AbcMetric do
  describe "#score" do
    it "returns 3.7417, which is the four decimal point" do
      abc_metric = CodeKeeper::Metrics::AbcMetric.new('spec/fixtures/branch_in_loop.rb')
      expect(abc_metric.score).to eq 3.7417
    end
  end
end
