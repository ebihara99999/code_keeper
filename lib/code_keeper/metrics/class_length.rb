# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Calculates class-like code length at the class/module scope.
    class ClassLength
      def self.measure(source_file)
        new(source_file).measure
      end

      def initialize(source_file)
        @source_file = source_file
        @path = @source_file.path
        @ps = @source_file.processed_source
        @body = @source_file.ast
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
            next if ScopeName.dynamic_singleton?(node)

            nodes << [node, :singleton_class, ScopeName.class_name(node)]
          elsif node.casgn_type?
            expression = ConstantAssignment.assigned_expression(node)
            next unless class_definition?(expression)

            nodes << [expression, :class, ScopeName.const_assignment_name(node)]
          end
        end

        nodes
      end

      def calculate(node)
        RuboCopMetricCalculator.class_length(node, @ps)
      end

      def class_definition?(node)
        node.respond_to?(:class_definition?) && node.class_definition?
      end
    end
  end
end
