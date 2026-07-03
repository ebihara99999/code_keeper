# frozen_string_literal: true

RSpec.describe CodeKeeper::MetricReport do
  describe '#to_h' do
    it 'summarizes measurements by metric' do
      metric_report = CodeKeeper::MetricReport.new
      metric_report.add(
        CodeKeeper::Measurement.new(
          metric: :abc_metric,
          scope_type: :method,
          scope_name: 'A#b',
          path: 'a.rb',
          start_line: 1,
          end_line: 3,
          value: 2.0
        )
      )

      expect(metric_report.to_h[:summary][:metrics][:abc_metric][:max]).to eq 2.0
    end

    it 'returns the top five hotspots by descending value' do
      metric_report = CodeKeeper::MetricReport.new(
        [1, 6, 3, 5, 2, 4].map.with_index do |value, index|
          measurement(value: value, path: "#{index}.rb", start_line: index + 1)
        end
      )

      expect(metric_report.to_h[:summary][:metrics][:abc_metric][:top_hotspots].map { |hotspot| hotspot[:value] }).to eq [6, 5, 4, 3, 2]
    end

    it 'orders hotspot ties by path and start line' do
      metric_report = CodeKeeper::MetricReport.new(
        [
          measurement(path: 'b.rb', start_line: 1, scope_name: 'B#b'),
          measurement(path: 'a.rb', start_line: 2, scope_name: 'A#b'),
          measurement(path: 'a.rb', start_line: 1, scope_name: 'A#a')
        ]
      )

      expect(metric_report.to_h[:summary][:metrics][:abc_metric][:top_hotspots].map { |hotspot| [hotspot[:path], hotspot[:start_line]] }).to eq(
        [['a.rb', 1], ['a.rb', 2], ['b.rb', 1]]
      )
    end
  end

  def measurement(value: 2.0, path: 'a.rb', start_line: 1, scope_name: 'A#b')
    CodeKeeper::Measurement.new(
      metric: :abc_metric,
      scope_type: :method,
      scope_name: scope_name,
      path: path,
      start_line: start_line,
      end_line: start_line + 2,
      value: value
    )
  end
end
