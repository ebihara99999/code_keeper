# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates class-like code length at the class/module scope.
    class ClassLength
      def self.measure(source_file)
        new(source_file, engine: :rubocop_standard).measure
      end

      def initialize(source_or_path, engine: CodeKeeper.config.metrics_engine)
        @source_file = source_or_path.is_a?(SourceFile) ? source_or_path : Parser.source_file(source_or_path)
        @path = @source_file.path
        @ps = @source_file.processed_source
        @body = @source_file.ast
        @engine = engine
      end

      def score
        return LegacyClassLength.new(@source_file).score if @engine == :legacy

        measure.to_h { |measurement| [measurement.legacy_key, measurement.value] }
      end

      def measure
        return [] unless @body

        classlike_nodes.map do |node, scope_type, scope_name|
          Measurement.new(
            metric: :class_length,
            scope_type: scope_type,
            scope_name: scope_name,
            path: @path,
            start_line: node.first_line,
            end_line: node.last_line,
            value: calculate(node)
          )
        end
      end

      private

      def classlike_nodes
        nodes = []

        @body.each_node(:class, :module, :sclass, :casgn) do |node|
          if node.class_type?
            nodes << [node, :class, ScopeName.class_name(node)]
          elsif node.module_type?
            nodes << [node, :module, ScopeName.class_name(node)]
          elsif node.sclass_type?
            next if node.each_ancestor(:class).any?

            nodes << [node, :singleton_class, ScopeName.class_name(node)]
          elsif node.casgn_type?
            expression = class_definition_expression(node)
            next unless class_definition?(expression)

            nodes << [expression, :class, ScopeName.const_assignment_name(node)]
          end
        end

        nodes
      end

      def calculate(node)
        RuboCopMetricCalculator.class_length(node, @ps)
      end

      def class_definition_expression(node)
        if node.respond_to?(:expression) && node.expression
          node.expression
        else
          find_expression_within_parent(node.parent)
        end
      end

      def find_expression_within_parent(parent)
        if parent&.assignment?
          parent.expression
        elsif parent&.parent&.masgn_type?
          parent.parent.expression
        end
      end

      def class_definition?(node)
        node.respond_to?(:class_definition?) && node.class_definition?
      end
    end
  end
end
