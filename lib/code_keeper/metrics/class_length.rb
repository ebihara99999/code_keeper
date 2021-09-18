# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Caluculate Class Length.
    class ClassLength
      def initialize(file_path)
        @ps = Parser.parse(file_path)
        @body = @ps.ast
        @score_hash = {}
        @klass_ns_mapping = {}
      end

      # NOTE: This doesn't exclude foldale sources like Array, Hash and Heredoc.
      def score
        @body.each_node(:class, :casgn, :module) do |node|
          build_namespace(node)
          if node.class_type? || node.module_type?
            _key = node.loc.name.source.to_sym
            @score_hash.store(@klass_ns_mapping[_key], calculate(node))
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
              _scope, klass_without_ns, block_node = *node
              klass = @klass_ns_mapping[klass_without_ns.to_sym]
            end

            # This is not to raise error on dynamic assignments like `X = Y = Z = Class.new`.
            # the block node is as follows if node is X:
            # `s(:casgn, nil, :Y, s(:casgn, nil, :Z, s(:block, ...`
            # Similarly the block node is `:X` as follows if node is Y.
            next unless block_node.respond_to?(:class_definition?) && block_node.class_definition?

            # if the parent is an assignment_type or the parent of the parent is a masgn_type,
            klass ||= @klass_ns_mapping[node.loc.name.source.to_sym]

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
        node.each_descendant(:class, :module).with_index do |klass_or_module_node, i|
          # Doesn't count inner nodes of the first inner node.
          # It's double counting.
          break unless i.zero?

          count += klass_or_module_node.nonempty_line_count
        end
        count
      end

      # Only counts the comment of the class or module of a node.
      # Because `#line_count_of_inner_nodes` only considers the first inner node,
      # the second or later inner nodes' commments are not necesarry to be counted.
      def comment_line_count(node)
        node_range = node.first_line...node.last_line
        comment_lines = @ps.comments.map { |comment| comment.loc.line }
        descendant_class_lines = []
        # A class may have multiple inner classes seperately.
        # So it needs to store all descendant classes line ranges.
        node.each_descendant(:class, :module) do |desendant|
          # To make easier to compare and consider inner nodes, change array of line range into an array of line numbers.
          descendant_class_lines << (desendant.first_line..desendant.last_line).to_a
        end

        # To make easier to compare, change array of line range into an array of line numbers.
        lines = descendant_class_lines.flatten.uniq

        # The latter condition considers a class ouside or above the node.
        comment_lines.select { |cl| !lines.include?(cl) && node_range.include?(cl) }.count
      end

      def build_namespace(node)
        ns = node.children.first&.namespace&.source
        self_name = if ns.nil?
                      node.children.first&.short_name.to_s
                    else
                      node.children.first.namespace.source + "::#{node.children.first.short_name}"
                    end

        return if @klass_ns_mapping.key? self_name.to_sym

        # The first class name has no namespace.
        @klass_ns_mapping.store(self_name.to_sym, self_name)
        name_with_ns = self_name.dup

        # To build namepace, const_node is enough. Class_node has more information than necesarry.
        # TODO This considers only nested classes. A class may have multiple classes seperately.
        node.each_descendant(:const) do |cnode|
          next unless cnode.parent.class_type? || cnode.parent.module_type?
          next if cnode.short_name.to_s == self_name

          ns = cnode.namespace&.source
          child_class_name = if ns.nil?
                               cnode.short_name
                             else
                               "#{cnode.namespace.source}::#{cnode.short_name}"
                             end
          name_with_ns = "#{name_with_ns}::#{child_class_name}"
          @klass_ns_mapping.store(child_class_name, name_with_ns)
        end
      end
    end
  end
end
