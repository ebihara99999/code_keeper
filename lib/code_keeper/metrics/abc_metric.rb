# frozen_string_literal: true

module CodeKeeper
  module Metrics
    # Caluculate cyclomatic complexity
    class AbcMetric
      include ::RuboCop::Cop::Metrics::Utils::IteratingBlock
      include ::RuboCop::Cop::Metrics::Utils::RepeatedCsendDiscount

      def initialize(file_path)
        ps = Parser.parse(file_path)
        @path = file_path
        @body = ps.ast
        @assignments = 0
        @branches = 0
        @conditionals = 0
      end

      def score
        caluculator = ::RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(@body)
        caluculator.calculate
        @assignments = caluculator.instance_variable_get('@assignment')
        @conditionals = caluculator.instance_variable_get('@condition')
        @branches = caluculator.instance_variable_get('@branch')

        value = Math.sqrt(@assignments**2 + @branches**2 + @conditionals**2).round(4)
        { "#{@path}": value }
      end
    end
  end
end
