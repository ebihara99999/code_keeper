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

      let(:expected_string) do
        %({\"cyclomatic_complexity\":{\"/foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb\":2,\"/foo/bar/code_keeper/spec/fixtures/target_sample.rb\":1}})
      end

      it 'returns an json string' do
        expect(CodeKeeper::Formatter.format(@result)).to eq expected_string
      end
    end
  end
end
