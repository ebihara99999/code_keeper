# frozen_string_literal: true

RSpec.describe CodeKeeper::Cli do
  describe '.run' do
    it 'returns Hash object which restores a file name as a key and score as a value' do
      result = CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'])
      expect(result).to be_a Hash
    end
  end
end
