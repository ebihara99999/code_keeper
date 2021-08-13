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
end
