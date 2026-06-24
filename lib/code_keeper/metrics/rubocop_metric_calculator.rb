# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Centralizes RuboCop metric calculation details.
    module RuboCopMetricCalculator
      module_function

      def abc_size(node)
        return 0 unless node

        value, = abc_calculator.calculate(node, discount_repeated_attributes: false)
        value
      rescue ArgumentError
        value, = abc_calculator.calculate(node)
        value
      end

      def cyclomatic_complexity(node)
        return 1 unless node

        cop = ::RuboCop::Cop::Metrics::CyclomaticComplexity.new
        cop.send(:reset_repeated_csend)
        cop.send(:complexity, node)
      end

      def class_length(node, processed_source)
        ::RuboCop::Cop::Metrics::Utils::CodeLengthCalculator.new(
          node,
          processed_source,
          count_comments: false,
          foldable_types: []
        ).calculate
      end

      def abc_calculator
        ::RuboCop::Cop::Metrics::Utils::AbcSizeCalculator
      end
    end
  end
end
