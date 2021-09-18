# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Caluculate Class Length.
    class ClassLength
      def initialize(file_path)
        @ps = Parser.parse(file_path)
        @body = @ps.ast
        @score_hash = {}
      end

      # NOTE: This doesn't exclude foldale sources like Array, Hash and Heredoc.
      def score
        @body.each_node(:class, :casgn, :module) do |node|
          if node.class_type? || node.module_type?
            _key = node.loc.name.source.to_sym
            @score_hash.store(build_namespace(node), calculate(node))
          elsif node.casgn_type?
            parent = node.parent

            if parent&.assignment?
              block_node = node.children[2]
            elsif parent&.parent&.masgn_type?
              # In the case where `A, B = Struct.new(:a, :b)`,
              # B is always nil.
              assigned = parent.loc.expression.source.split(',').first
              next unless node.loc.name.source == assigned

              block_node = parent.parent.children[1]
            else
              _scope, _klass, block_node = *node
            end

            # This is not to raise error on dynamic assignments like `X = Y = Z = Class.new`.
            # the block node is as follows if node is X:
            # `s(:casgn, nil, :Y, s(:casgn, nil, :Z, s(:block, ...`
            # Similarly the block node is `:X` as follows if node is Y.
            next unless block_node.respond_to?(:class_definition?) && block_node.class_definition?

            # if the parent is an assignment_type or the parent of the parent is a masgn_type,
            #klass ||= @klass_ns_mapping[node.loc.name.source.to_sym]

            @score_hash.store(build_namespace(block_node), calculate(block_node))
          end
        end
        @score_hash
      end

      private

      def calculate(node)
        # node.body.line_count doesn't include comments after definition of a class.
        # Don't use nonempty_lines. Empty lines are considered on only the node.
        count = node.line_count - 2

        count - line_count_of_inner_nodes(node) - comment_line_count(node) - empty_line_count(node)
      end

      def body_lines(node)
        (node.first_line..node.last_line).to_a - descendant_class_lines(node)
      end

      def descendant_class_lines(node)
        # A class may have multiple inner classes seperately.
        # So it needs to store all descendant classes line ranges.
        node.each_descendant(:class, :module).map do |desendant|
          # To make easier to compare and consider inner nodes, change array of line range into an array of line numbers.
          (desendant.first_line..desendant.last_line).to_a
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

      # Only counts the comment of the class or module of a node.
      # Because `#line_count_of_inner_nodes` only considers the first inner node,
      # the second or later inner nodes' commments are not necesarry to be counted.
      def comment_line_count(node)
        node_range = node.first_line...node.last_line
        comment_lines = @ps.comments.map { |comment| comment.loc.line }
        # The latter condition considers a class ouside or above the node.
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
