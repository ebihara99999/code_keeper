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
        @body.each_node(:class, :casgn) do |node|
          if node.class_type?
            @score_hash.store(node.loc.name.source.to_sym, calculate(node))
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
              _scope, klass, block_node = *node
            end

            # This is not to raise error on dynamic assignments like `X = Y = Z = Class.new`.
            # the block node is as follows if node is X:
            # `s(:casgn, nil, :Y, s(:casgn, nil, :Z, s(:block, ...`
            # Similarly the block node is `:X` as follows if node is Y.
            next unless block_node.respond_to?(:class_definition?) && block_node.class_definition?

            # if the parent is an assignment_type or the parent of the parent is a masgn_type,
            klass ||= node.loc.name.source.to_sym

            @score_hash.store(klass, calculate(block_node))
          end
        end
        @score_hash
      end

      private

      def calculate(node)
        # node.body.line_count doesn't include comments after definition of a class.
        count = node.nonempty_line_count - 2
        count - line_count_of_inner_nodes(node) - comment_line_count(node)
      end

      def line_count_of_inner_nodes(node)
        count = 0
        node.each_descendant(:class, :module) do |klass_or_module_node|
          count += klass_or_module_node.nonempty_line_count
        end
        count
      end

      def comment_line_count(node)
        count = 0
        @ps.comments.each do |comment|
          count += 1 if (node.first_line...node.last_line).include? comment.loc.line
        end
        count
      end
    end
  end
end
