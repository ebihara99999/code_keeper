# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::CyclomaticComplexity do
  describe "#score" do
    it 'returns RuboCop cyclomatic complexity values by method scope' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_cop = RuboCop::Cop::Metrics::CyclomaticComplexity.new
      rubocop_cop.send(:reset_repeated_csend)
      complexity = CodeKeeper::Metrics::CyclomaticComplexity.new(source_file)

      expect(complexity.score).to eq(
        'spec/fixtures/branch_in_loop.rb:two_hundred' => rubocop_cop.send(:complexity, method_node.body)
      )
    end
  end

  describe '.measure' do
    it 'matches RuboCop cyclomatic complexity calculation' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_cop = RuboCop::Cop::Metrics::CyclomaticComplexity.new
      rubocop_cop.send(:reset_repeated_csend)
      measurement = CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).first

      expect(measurement.value).to eq rubocop_cop.send(:complexity, method_node.body)
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).map(&:scope_name)).to eq ['ConfigIgnoredSample#complex_method']
    end
  end
end
