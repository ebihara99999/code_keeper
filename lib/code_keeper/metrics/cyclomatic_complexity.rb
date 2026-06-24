# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates cyclomatic complexity at the method scope.
    class CyclomaticComplexity
      include ::RuboCop::Cop::Metrics::Utils::IteratingBlock
      include ::RuboCop::Cop::Metrics::Utils::RepeatedCsendDiscount

      LEGACY_CONSIDERED_NODES = %i[if while until for csend block block_pass rescue when and or or_asgnand_asgn].freeze

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

      def legacy_score
        final_score = @body.each_node(:lvasgn, *LEGACY_CONSIDERED_NODES).reduce(1) do |score, node|
          next score if !iterating_block?(node) || node.lvasgn_type?
          next score if node.csend_type? && discount_for_repeated_csend?(node)

          next 1 + score
        end
        { "#{@path}": final_score }
      end
    end
  end
end
