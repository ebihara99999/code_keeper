# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates ABC size at the method scope.
    class AbcMetric
      def self.measure(source_file)
        new(source_file).measure
      end

      def initialize(source_file)
        @source_file = source_file
        @path = @source_file.path
        @body = @source_file.ast
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
        RuboCopMetricCalculator.abc_size(node)
      end
    end
  end
end
