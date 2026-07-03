# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::ClassLength do
  describe '.measure' do
    it 'returns measurements by class scope' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/class_samples/simple_class.rb')
      measurement = CodeKeeper::Metrics::ClassLength.measure(source_file).first

      expect(measurement.scope_name).to eq 'SimpleClass'
    end

    it 'matches RuboCop code length calculation' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/class_samples/simple_class.rb')
      class_node = source_file.ast.each_node(:class).first
      rubocop_value = RuboCop::Cop::Metrics::Utils::CodeLengthCalculator.new(
        class_node,
        source_file.processed_source,
        count_comments: false,
        foldable_types: []
      ).calculate
      measurement = CodeKeeper::Metrics::ClassLength.measure(source_file).first

      expect(measurement.value).to eq rubocop_value
    end
  end
end
