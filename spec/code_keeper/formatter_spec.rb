# frozen_string_literal: true

RSpec.describe CodeKeeper::Formatter do
  describe '.format' do
    context 'it shows a filename' do
      let(:expected_string) do
        <<~EOS
          Scores:

          Metric: cyclomatic_complexity
          Filename: /foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb
          Score: 2
          ---
          Metric: cyclomatic_complexity
          Filename: /foo/bar/code_keeper/spec/fixtures/target_sample.rb
          Score: 1
          ---
        EOS
      end

      before do
        CodeKeeper.configure do |config|
          config.metrics = [:cyclomatic_complexity]
        end

        @result = CodeKeeper::Result.new
        @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb', 2)
        @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/target_sample.rb', 1)
      end

      it 'returns an string' do
        expect(CodeKeeper::Formatter.format(@result)).to eq expected_string
      end
    end

    context 'it shows a class name' do
      let(:expected_string) do
        <<~EOS
          Scores:

          Metric: class_length
          Class: SimpleClass
          Score: 2
          ---
          Metric: class_length
          Class: NameSpaceClass
          Score: 3
          ---
        EOS
      end

      before do
        CodeKeeper.configure do |config|
          config.metrics = [:class_length]
        end

        @result = CodeKeeper::Result.new
        @result.add(:class_length, 'SimpleClass', 2)
        @result.add(:class_length, 'NameSpaceClass', 3)
      end

      it 'returns an string' do
        expect(CodeKeeper::Formatter.format(@result)).to eq expected_string
      end
    end
  end
end
