# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates ABC size at the method scope.
    class AbcMetric
      def self.measure(source_file)
        new(source_file, engine: :rubocop_standard).measure
      end

      def initialize(source_or_path, engine: CodeKeeper.config.metrics_engine)
        @source_file = source_or_path.is_a?(SourceFile) ? source_or_path : Parser.source_file(source_or_path)
        @path = @source_file.path
        @body = @source_file.ast
        @engine = engine
      end

      def score
        return legacy_score if @engine == :legacy

        measure.to_h { |measurement| [measurement.legacy_key, measurement.value] }
      end

      def measure
        return [] unless @body

        method_nodes.map do |node|
          Measurement.new(
            metric: :abc_metric,
            scope_type: :method,
            scope_name: ScopeName.method_name(node),
            path: @path,
            start_line: node.first_line,
            end_line: node.last_line,
            value: calculate(node.body)
          )
        end
      end

      private

      def method_nodes
        @body.each_node(:def, :defs, :block, :numblock, :itblock).select do |node|
          node.def_type? || node.defs_type? || ScopeName.define_method?(node)
        end
      end

      def calculate(node)
        return 0 unless node

        calculator = ::RuboCop::Cop::Metrics::Utils::AbcSizeCalculator
        value, = calculator.calculate(node, discount_repeated_attributes: false)
        value
      rescue ArgumentError
        value, = calculator.calculate(node)
        value
      end

      def legacy_score
        calculator = ::RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(@body)
        calculator.calculate
        assignments = calculator.instance_variable_get('@assignment')
        conditionals = calculator.instance_variable_get('@condition')
        branches = calculator.instance_variable_get('@branch')

        value = Math.sqrt(assignments**2 + branches**2 + conditionals**2).round(4)
        { "#{@path}": value }
      end
    end
  end
end
