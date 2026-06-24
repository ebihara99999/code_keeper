# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::CyclomaticComplexity do
  describe "#score" do
    before do
      CodeKeeper.configure do |config|
        config.metrics_engine = :legacy
      end
    end

    it 'returns a hash with score of a file' do
      expected_hash = { 'spec/fixtures/branch_in_loop.rb': 2 }
      complexity = CodeKeeper::Metrics::CyclomaticComplexity.new('spec/fixtures/branch_in_loop.rb')
      expect(complexity.score).to eq expected_hash
    end
  end

  describe '.measure' do
    it 'returns RuboCop-style method complexity' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      measurement = CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).first

      expect(measurement.value).to eq 3
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).size).to eq 1
    end
  end
end
