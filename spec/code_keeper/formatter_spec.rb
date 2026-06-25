# frozen_string_literal: true

RSpec.describe CodeKeeper::Formatter do
  describe '.format' do
    before do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end

      @result = CodeKeeper::Result.new
      @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb', 2)
      @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/target_sample.rb', 1)
    end

    context 'csv format' do
      before do
        CodeKeeper.configure do |config|
          config.format = :csv
        end
      end

      let(:expected_string) do
        <<~EOS
         metric,file,score
         cyclomatic_complexity,/foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb,2
         cyclomatic_complexity,/foo/bar/code_keeper/spec/fixtures/target_sample.rb,1
        EOS
      end

      it 'returns an csv string' do
        expect(CodeKeeper::Formatter.format(@result)).to eq expected_string
      end
    end

    context 'json format' do
      before do
        CodeKeeper.configure do |config|
          config.format = :json
        end
      end

      it 'returns metric report json' do
        @result.add_measurement(
          CodeKeeper::Measurement.new(
            metric: :cyclomatic_complexity,
            scope_type: :method,
            scope_name: 'Sample#hello',
            path: '/foo/bar/code_keeper/spec/fixtures/target_sample.rb',
            start_line: 2,
            end_line: 4,
            value: 1
          )
        )
        json = JSON.parse(CodeKeeper::Formatter.format(@result))

        expect(json.dig('summary', 'metrics', 'cyclomatic_complexity', 'max')).to eq 1
      end
    end
  end
end
