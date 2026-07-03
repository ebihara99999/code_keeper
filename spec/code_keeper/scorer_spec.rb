# frozen_string_literal: true

RSpec.describe CodeKeeper::Scorer do
  describe '.keep' do
    it 'returns an instance of CodeKeeper::MetricReport' do
      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb'])).to be_a CodeKeeper::MetricReport
    end

    it 'stores metric measurements' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end

      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb']).measurements.size).to eq 1
    end

    it 'measures duplicated configured metrics once' do
      CodeKeeper.configure do |config|
        config.metrics = %i[cyclomatic_complexity cyclomatic_complexity]
      end

      expect(CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb']).measurements.size).to eq 1
    end

    it 'stores parallel measurements in input order' do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
        config.number_of_threads = 2
      end

      metric_report = CodeKeeper::Scorer.keep(['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'])

      expect(metric_report.measurements.map { |measurement| [measurement.path, measurement.scope_name] }).to eq(
        [
          ['./spec/fixtures/branch_in_loop.rb', 'two_hundred'],
          ['./spec/fixtures/target_sample.rb', 'TargetSample#hello']
        ]
      )
    end
  end
end
