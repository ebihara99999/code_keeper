# frozen_string_literal: true

RSpec.describe CodeKeeper::Result do
  describe '#add' do
    before do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end

      @result = CodeKeeper::Result.new
      @result.add(:cyclomatic_complexity, './spec/fixtures/branch_in_loop.rb', 2)
    end

    it 'stores path and score' do
      # HACK: if you dont use store, a colon is stick to the key if it starts with a dot.
      # > hoge = { hoge: { 'fuga': 2 } }
      # => {:hoge=>{:fuga=>2}}
      # > hoge = { hoge: { './fuga': 2 } }
      # => {:hoge=>{:"./fuga"=>2}}
      expected_hash = { cyclomatic_complexity: {} }
      expected_hash[:cyclomatic_complexity].store('./spec/fixtures/branch_in_loop.rb', 2)

      expect(@result.scores).to eq expected_hash
    end
  end

  describe '#add_measurement' do
    it 'stores measurement in the metric report' do
      result = CodeKeeper::Result.new
      measurement = CodeKeeper::Measurement.new(
        metric: :abc_metric,
        scope_type: :method,
        scope_name: 'A#b',
        path: 'a.rb',
        start_line: 1,
        end_line: 3,
        value: 2.0
      )

      result.add_measurement(measurement)

      expect(result.metric_report.measurements).to eq [measurement]
    end
  end
end
