# frozen_string_literal: true

RSpec.describe CodeKeeper::Scorer do
  describe '.keep' do
    it 'returns an instance of CodeKeeper::Result' do
      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb'])).to be_a CodeKeeper::Result
    end
  end
end
