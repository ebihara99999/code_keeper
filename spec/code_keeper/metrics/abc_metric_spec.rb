# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::AbcMetric do
  describe "#score" do
    it 'returns RuboCop ABC values by method scope' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_value, = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(
        method_node.body,
        discount_repeated_attributes: false
      )
      abc_metric = CodeKeeper::Metrics::AbcMetric.new(source_file)

      expect(abc_metric.score).to eq('spec/fixtures/branch_in_loop.rb:two_hundred' => rubocop_value)
    end
  end

  describe '.measure' do
    it 'returns measurements by method scope' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      measurement = CodeKeeper::Metrics::AbcMetric.measure(source_file).first

      expect(measurement.scope_name).to eq 'two_hundred'
    end

    it 'matches RuboCop ABC calculation' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_value, = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(
        method_node.body,
        discount_repeated_attributes: false
      )
      measurement = CodeKeeper::Metrics::AbcMetric.measure(source_file).first

      expect(measurement.value).to eq rubocop_value
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::Parser.source_file('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::AbcMetric.measure(source_file).map(&:scope_name)).to eq ['ConfigIgnoredSample#complex_method']
    end
  end
end
