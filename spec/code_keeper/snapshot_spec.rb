# frozen_string_literal: true

RSpec.describe CodeKeeper::Snapshot do
  describe '#to_h' do
    it 'summarizes measurements by metric' do
      snapshot = CodeKeeper::Snapshot.new
      snapshot.add(
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

      expect(snapshot.to_h[:summary][:metrics][:abc_metric][:max]).to eq 2.0
    end
  end
end
