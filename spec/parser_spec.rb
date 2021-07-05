# frozen_string_literal: true

RSpec.describe CodeKeeper::Parser do
  describe '#initialize' do
    it 'returns string source codes' do
    end

    context 'File does not exsit' do
      it 'raises TargetFileNotFoundError' do
      end
    end
  end

  describe '.parse' do
    it 'returns RuboCop::AST::ProcessedSource instance' do
    end
  end
end
