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

    it 'stores processed_source' do
      expect(CodeKeeper::SourceFile.new('./spec/fixtures/target_sample.rb').processed_source).to be_a(::RuboCop::AST::ProcessedSource)
    end

    context 'when the file path is absolute' do
      it 'stores processed_source' do
        absolute_path = File.join(Dir.pwd, 'spec/fixtures/target_sample.rb')
        expect(CodeKeeper::SourceFile.new(absolute_path).processed_source).to be_a(::RuboCop::AST::ProcessedSource)
      end
    end

    context 'when the file does not exist' do
      it 'raises TargetFileNotFoundError' do
        expect do
          CodeKeeper::SourceFile.new('./spec/fixtures/no_file.rb')
        end.to raise_error CodeKeeper::TargetFileNotFoundError
      end
    end
  end
end
