# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates cyclomatic complexity at the method scope.
    class CyclomaticComplexity
      include ::RuboCop::Cop::Metrics::Utils::IteratingBlock
      include ::RuboCop::Cop::Metrics::Utils::RepeatedCsendDiscount

      def self.measure(source_file)
        new(source_file).measure
      end

      def initialize(source_file)
        @source_file = source_file
        @path = @source_file.path
        @body = @source_file.ast
      end

      def score
        measure.to_h { |measurement| [measurement.score_key, measurement.value] }
      end

      def measure
        return [] unless @body

        method_nodes.map do |node|
          Measurement.new(
            metric: :cyclomatic_complexity,
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

      def calculate(body)
        RuboCopMetricCalculator.cyclomatic_complexity(body)
      end
    end
  end
end
