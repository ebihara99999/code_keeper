module CodeKeeper
  # Caluculate cyclomatic complexity
  class CyclomaticComplexity
    include ::RuboCop::Cop::Metrics::Utils::IteratingBlock
    include ::RuboCop::Cop::Metrics::Utils::RepeatedCsendDiscount

    CONSIDERED_NODES = %i[if while until for csend block block_pass rescue when and or or_asgnand_asgn].freeze

    def initialize(source)
      ps = ::RuboCop::AST::ProcessedSource.new(source, 3.0)
      @body = ps.ast.body
    end

    # returns score of cyclomatic complexity
    def score
      @body.each_node(:lvasgn, *CONSIDERED_NODES).reduce(1) do |score, node|
        if !iterating_block?(node)
          next score
        elsif node.csend_type? && discount_for_repeated_csend?(node)
          next score
        elsif node.lvasgn_type?
          next score
        else
          next 1 + score
        end
      end
    end
  end
end
