# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Builds human-readable source scope names from RuboCop AST nodes.
    module ScopeName
      module_function

      def method_name(node)
        case node.type
        when :def
          join_instance_method(owner_name(node), node.method_name)
        when :defs
          join_singleton_method(singleton_receiver_name(node), node.method_name)
        else
          define_method_name(node)
        end
      end

      def class_name(node)
        case node.type
        when :sclass
          "class << #{node.children.first.source}"
        else
          join_const_name(owner_name(node), node.children.first&.source)
        end
      end

      def const_assignment_name(node)
        scope, name = *node
        const_name = join_const_name(scope&.source, name)
        return const_name unless scope.nil?

        join_const_name(owner_name(node), const_name)
      end

      def define_method?(node)
        return false unless %i[block numblock itblock].include?(node.type)

        send_node = node.children.first
        return false unless send_node&.send_type?
        return false unless send_node.method_name == :define_method
        return false unless send_node.receiver.nil?

        literal_name?(send_node.arguments.first)
      end

      def define_method_name(node)
        send_node = node.children.first
        name = literal_value(send_node.arguments.first)

        join_instance_method(owner_name(node), name)
      end

      def owner_name(node)
        node.each_ancestor(:class, :module).to_a.reverse.filter_map do |ancestor|
          class_name(ancestor)
        end.join('::')
      end

      def join_instance_method(owner, name)
        return name.to_s if owner.nil? || owner.empty?

        "#{owner}##{name}"
      end

      def join_singleton_method(receiver, name)
        return name.to_s if receiver.nil? || receiver.empty?

        "#{receiver}.#{name}"
      end

      def join_const_name(namespace, name)
        return name.to_s if namespace.nil? || namespace.empty?
        return namespace.to_s if name.nil? || name.to_s.empty?

        "#{namespace}::#{name}"
      end

      def singleton_receiver_name(node)
        receiver = node.children.first
        return owner_name(node) if receiver&.self_type? && !owner_name(node).empty?

        receiver&.source
      end

      def literal_name?(node)
        node&.sym_type? || node&.str_type?
      end

      def literal_value(node)
        if node.respond_to?(:value)
          node.value
        else
          node.children.first
        end
      end
    end
  end
end
