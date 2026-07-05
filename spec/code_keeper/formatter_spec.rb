# frozen_string_literal: true

RSpec.describe CodeKeeper::Formatter do
  describe '.format' do
    it 'returns metric report json' do
      metric_report = CodeKeeper::MetricReport.new(
        [
          CodeKeeper::Measurement.new(
            metric: :cyclomatic_complexity,
            scope_type: :method,
            scope_name: 'Sample#hello',
            path: './spec/fixtures/target_sample.rb',
            start_line: 2,
            end_line: 4,
            value: 1
          )
        ]
      )
      json = JSON.parse(CodeKeeper::Formatter.format(metric_report))

      expect(json.dig('summary', 'metrics', 'cyclomatic_complexity', 'max')).to eq 1
    end
  end
end
