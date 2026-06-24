# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Keeps the historical CodeKeeper class length calculation for migration.
    class LegacyClassLength
      def initialize(source_file)
        @ps = source_file.processed_source
        @body = source_file.ast
      end

      def score
        score_hash = {}

        @body.each_node(:class, :casgn, :module) do |node|
          if node.class_type? || node.module_type?
            score_hash.store(build_namespace(node), calculate(node))
          elsif node.casgn_type?
            score_for_const_assignment(score_hash, node)
          end
        end

        score_hash
      end

      private

      def score_for_const_assignment(score_hash, node)
        klass, block_node = const_assignment_parts(node)
        return unless class_definition?(block_node)

        score_hash.store(klass || build_namespace(block_node), calculate(block_node))
      end

      def const_assignment_parts(node)
        parent = node.parent
        return [node.loc.name.source, node.children[2]] if parent&.assignment?
        return multiple_const_assignment_parts(node, parent) if parent&.parent&.masgn_type?

        _scope, klass, block_node = *node
        [klass.to_s, block_node]
      end

      def multiple_const_assignment_parts(node, parent)
        assigned = parent.loc.expression.source.split(',').first
        return unless node.loc.name.source == assigned

        [node.loc.name.source, parent.parent.children[1]]
      end

      def class_definition?(node)
        node.respond_to?(:class_definition?) && node.class_definition?
      end

      def calculate(node)
        count = node.line_count - 2

        count - line_count_of_inner_nodes(node) - comment_line_count(node) - empty_line_count(node)
      end

      def body_lines(node)
        (node.first_line..node.last_line).to_a - descendant_class_lines(node)
      end

      def descendant_class_lines(node)
        node.each_descendant(:class, :module).map do |descendant|
          (descendant.first_line..descendant.last_line).to_a
        end.flatten.uniq
      end

      def empty_line_count(node)
        empty_lines = @ps.lines.filter_map.with_index { |line, i| i + 1 if line.empty? }
        (empty_lines & body_lines(node)).size
      end

      def line_count_of_inner_nodes(node)
        line_numbers = node.each_descendant(:class, :module).map do |descendant|
          (descendant.first_line..descendant.last_line).to_a
        end.flatten.uniq

        line_numbers.size
      end

      def comment_line_count(node)
        node_range = node.first_line...node.last_line
        comment_lines = @ps.comments.map { |comment| comment.loc.line }
        comment_lines.select { |cl| !descendant_class_lines(node).include?(cl) && node_range.include?(cl) }.count
      end

      def build_namespace(node)
        self_name = name_with_ns(node)

        return self_name if node.each_ancestor(:class, :module).to_a.empty?

        full_name = self_name.dup
        node.each_ancestor(:class, :module) do |ancestor|
          full_name = "#{name_with_ns(ancestor)}::#{full_name}"
        end
        full_name
      end

      def name_with_ns(node)
        ns = node.children.first&.namespace&.source
        if ns.nil?
          node.children.first&.short_name.to_s
        else
          node.children.first.namespace.source + "::#{node.children.first.short_name}"
        end
      end
    end
  end
end
