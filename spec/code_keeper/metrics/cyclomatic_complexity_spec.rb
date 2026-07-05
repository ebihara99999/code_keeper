# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::CyclomaticComplexity do
  describe '.measure' do
    it 'matches RuboCop cyclomatic complexity calculation' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/branch_in_loop.rb')
      method_node = source_file.ast.each_node(:def).first
      rubocop_cop = RuboCop::Cop::Metrics::CyclomaticComplexity.new
      rubocop_cop.send(:reset_repeated_csend)
      measurement = CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).first

      expect(measurement.value).to eq rubocop_cop.send(:complexity, method_node.body)
    end

    it 'does not suppress measurements with RuboCop comments or config' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/rubocop_config/sample.rb')

      expect(CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).map(&:scope_name)).to eq ['ConfigIgnoredSample#complex_method']
    end

    it 'names methods in singleton class scopes as singleton methods' do
      source_file = CodeKeeper::SourceFile.new('spec/fixtures/class_samples/singleton_scope.rb')

      expect(CodeKeeper::Metrics::CyclomaticComplexity.measure(source_file).map(&:scope_name)).to eq(
        [
          'SingletonScopeSample.module_singleton_method',
          'SingletonScopeOwner.class_singleton_method',
          'SingletonScopeOwner.defined_singleton_method',
          'SingletonScopeOwner.build_helper',
          'SingletonScopeOwner#built_instance_method',
          'SingletonScopeRuntime#attach',
          'self.tag',
          'SingletonScopeRuntime#decorate',
          'target.label',
          'SingletonScopeRuntime#register',
          'self.runtime_singleton',
          'SingletonScopeOwner.const_singleton_method',
          'self.top_level_singleton_method'
        ]
      )
    end
  end
end
