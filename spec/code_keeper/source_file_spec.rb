# frozen_string_literal: true

RSpec.describe CodeKeeper::SourceFile do
  describe '#initialize' do
    it 'stores path' do
      expect(CodeKeeper::SourceFile.new('./spec/fixtures/target_sample.rb').path).to eq './spec/fixtures/target_sample.rb'
    end

    it 'stores ast' do
      expect(CodeKeeper::SourceFile.new('./spec/fixtures/target_sample.rb').ast).not_to be_nil
    end

    it 'stores comments' do
      expect(CodeKeeper::SourceFile.new('./spec/fixtures/target_sample.rb').comments).to eq []
    end

    it 'stores lines' do
      expect(CodeKeeper::SourceFile.new('./spec/fixtures/target_sample.rb').lines).to include('class TargetSample')
    end
  end
end
