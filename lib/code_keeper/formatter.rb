# frozen_string_literal: true

module CodeKeeper
  # Format a result and make it human-readable.
  class Formatter
    class << self
      def format(result)
        title = "Scores:\n"
        formatted_result = +title
        result.each do |k, v|
          formatted_result.concat(
            <<~EOS
              filename: #{k}
              score: #{v}
              ---
            EOS
          )
        end
        formatted_result
      end
    end
  end
end
