# frozen_string_literal: true

RSpec.describe "CyclomaticComplexity" do
  describe "#score" do
    it "returns 2" do
      complexity = CodeKeeper::CyclomaticComplexity.new('spec/fixtures/branch_in_loop.rb')
      expect(complexity.score).to eq 2
    end
  end
end
