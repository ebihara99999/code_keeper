# frozen_string_literal: true

RSpec.describe CodeKeeper::Parser do
  describe '#initialize' do
    context 'file path is absolute' do
      it 'stores processed_source' do
        parser = CodeKeeper::Parser.new('./spec/fixtures/target_sample.rb')
        expect(parser.processed_source).to be_a(::RuboCop::AST::ProcessedSource)
      end
    end

    context 'file path is relative' do
      it 'stores processed_source' do
        absolute_spec_dir = File.join(Dir.pwd, 'spec')
        parser = CodeKeeper::Parser.new("#{absolute_spec_dir}/fixtures/target_sample.rb")
        expect(parser.processed_source).to be_a(::RuboCop::AST::ProcessedSource)
      end
    end

    context 'File does not exsit' do
      it 'raises TargetFileNotFoundError' do
        expect { CodeKeeper::Parser.new('./spec/fixtures/no_file.rb') }.to raise_error CodeKeeper::TargetFileNotFoundError
      end
    end
  end

  describe '.parse' do
    it 'returns RuboCop::AST::ProcessedSource instance' do
    end
  end
end
