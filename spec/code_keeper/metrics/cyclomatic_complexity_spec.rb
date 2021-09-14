# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::CyclomaticComplexity do
  describe "#score" do
    it 'returns a hash with score of a file' do
      expected_hash = { 'spec/fixtures/branch_in_loop.rb': 2 }
      complexity = CodeKeeper::Metrics::CyclomaticComplexity.new('spec/fixtures/branch_in_loop.rb')
      expect(complexity.score).to eq expected_hash
    end
  end
end
