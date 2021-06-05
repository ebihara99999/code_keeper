# frozen_string_literal: true

RSpec.describe "CyclomaticComplexity" do
  describe "#score" do
    let(:source) { "def hoge;[100, 200, 300].each { |num| puts num  if num == 200 };end" }

    it "returns 2" do
      complexity = CodeKeeper::CyclomaticComplexity.new(source)
      expect(complexity.score).to eq 2
    end
  end
end
