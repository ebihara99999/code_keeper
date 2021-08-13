# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::CyclomaticComplexity do
  describe "#score" do
    it "returns 2" do
      complexity = CodeKeeper::Metrics::CyclomaticComplexity.new('spec/fixtures/branch_in_loop.rb')
      expect(complexity.score).to eq 2
    end
  end
end
