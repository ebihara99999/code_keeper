# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::AbcMetric do
  describe '.measure' do
    it 'returns measurements by method scope' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/branch_in_loop.rb')
      measurement = CodeKeeper::Metrics::AbcMetric.measure(source_file).first

      expect(measurement.scope_name).to eq 'two_hundred'
    end

    it 'matches RuboCop ABC calculation' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_value, = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(
        method_node.body,
        discount_repeated_attributes: false
      )
      measurement = CodeKeeper::Metrics::AbcMetric.measure(source_file).first

      expect(measurement.value).to eq rubocop_value
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::AbcMetric.measure(source_file).map(&:scope_name)).to eq ['ConfigIgnoredSample#complex_method']
    end
  end
end
