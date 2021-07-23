# frozen_string_literal: true

RSpec.describe CodeKeeper::Cli do
  describe '.run' do
    it 'returns String object which is formatted by CodeKeeper::Formatter' do
      result = CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'])
      expect(result).to be_a String
    end
  end
end
