# frozen_string_literal: true

RSpec.describe CodeKeeper::Scorer do
  describe '.keep' do
    it 'returns an instance of CodeKeeper::Result' do
      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb'])).to be_a CodeKeeper::Result
    end

    it 'stores measurements with the standard engine' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end

      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb']).snapshot.measurements.size).to eq 1
    end

    it 'stores legacy scores with the legacy engine' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
        config.metrics_engine = :legacy
      end

      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb']).scores[:cyclomatic_complexity].values).to eq [2]
    end
  end
end
