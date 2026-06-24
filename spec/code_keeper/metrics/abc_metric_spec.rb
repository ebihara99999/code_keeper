# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::AbcMetric do
  describe "#score" do
    before do
      CodeKeeper.configure do |config|
        config.metrics_engine = :legacy
      end
    end

    it "returns a hash of a filename and a score, 3.7417, which is the four decimal point" do
      expected_hash = { 'spec/fixtures/branch_in_loop.rb': 3.7417 }
      abc_metric = CodeKeeper::Metrics::AbcMetric.new('spec/fixtures/branch_in_loop.rb')
      expect(abc_metric.score).to eq expected_hash
    end
  end

  describe '.measure' do
    it 'returns measurements by method scope' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      measurement = CodeKeeper::Metrics::AbcMetric.measure(source_file).first

      expect(measurement.scope_name).to eq 'two_hundred'
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::AbcMetric.measure(source_file).size).to eq 1
    end
  end
end
