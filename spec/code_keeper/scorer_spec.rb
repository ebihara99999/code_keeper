# frozen_string_literal: true

RSpec.describe CodeKeeper::Scorer do
  describe '.keep' do
    it 'returns an instance of CodeKeeper::Result' do
      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb'])).to be_a CodeKeeper::Result
    end

    it 'stores metric measurements' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end

      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb']).snapshot.measurements.size).to eq 1
    end

    it 'stores parallel measurements in input order' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
        config.number_of_threads = 2
      end

      result = CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'])

      expect(result.snapshot.measurements.map { |measurement| [measurement.path, measurement.scope_name] }).to eq(
        [
          ['./spec/fixtures/branch_in_loop.rb', 'two_hundred'],
          ['./spec/fixtures/target_sample.rb', 'TargetSample#hello']
        ]
      )
    end
  end
end
