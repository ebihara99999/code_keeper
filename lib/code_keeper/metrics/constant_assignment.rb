# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Resolves which expression a constant assignment actually receives,
    # including multiple assignment and nested destructuring.
    module ConstantAssignment
      module_function

      def assigned_expression(node)
        return node.expression if node.respond_to?(:expression) && node.expression

        parent = node.parent
        return parent.expression if parent&.assignment?

        masgn_expression(node) if parent&.mlhs_type?
      end

      # Resolves a multiple-assignment right-hand side: walk up nested
      # destructuring collecting positions, then walk the right-hand side back
      # down by position.
      def masgn_expression(node)
        positions = []
        child = node
        parent = node.parent

        while parent&.mlhs_type?
          position = position_in(parent.children, child)
          return unless position

          positions.unshift(position)
          child = parent
          parent = parent.parent
        end

        resolve_positions(parent, positions)
      end

      def resolve_positions(masgn, positions)
        return unless masgn&.masgn_type?

        positions.reduce(masgn.expression) do |expression, position|
          break unless expression

          resolve_position(expression, position)
        end
      end

      def position_in(siblings, child)
        # AST nodes compare structurally, so duplicated constants in the
        # left-hand side would all match the first position; locate by
        # object identity.
        index = siblings.find_index { |sibling| sibling.equal?(child) }
        position_for(siblings, index) if index
      end

      def position_for(siblings, index)
        {
          index:,
          splat_before: siblings.take(index).any?(&:splat_type?),
          fixed_before: siblings.take(index).count { |sibling| !sibling.splat_type? },
          from_end: siblings.size - 1 - index,
          fixed: siblings.count { |sibling| !sibling.splat_type? }
        }
      end

      # An array element is assigned by position; any other right-hand side
      # becomes a single-element list, so only the first fixed position
      # receives it and the rest become nil.
      def resolve_position(expression, position)
        if expression.array_type?
          resolve_array_position(expression, position)
        elsif position[:fixed_before].zero?
          expression
        end
      end

      # A splat in the right-hand side has an unknown length, so only elements
      # before the first splat (from the start) and after the last splat (from
      # the end) are statically determined; everything else stays unresolved.
      def resolve_array_position(expression, position)
        elements = expression.children
        first_splat = elements.index(&:splat_type?)

        if position[:splat_before]
          resolve_from_end(elements, first_splat, position)
        elsif first_splat.nil? || position[:index] < first_splat
          elements[position[:index]]
        end
      end

      def resolve_from_end(elements, first_splat, position)
        if first_splat.nil?
          return if elements.size < position[:fixed]
        else
          suffix_size = elements.size - 1 - elements.rindex(&:splat_type?)
          return unless position[:from_end] < suffix_size
        end

        elements[elements.size - 1 - position[:from_end]]
      end
    end
  end
end
