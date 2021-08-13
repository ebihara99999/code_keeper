# frozen_string_literal: true

RSpec.describe CodeKeeper::Formatter do
  describe '.format' do
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
      @result = CodeKeeper::Result.new
      @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/branch_in_loop.rb', 2)
      @result.add(:cyclomatic_complexity, '/foo/bar/code_keeper/spec/fixtures/target_sample.rb', 1)
    end

    it 'returns an string' do
      expect(CodeKeeper::Formatter.format(@result)).to eq expected_string
    end
  end
end
