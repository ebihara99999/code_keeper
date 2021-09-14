# frozen_string_literal: true

module CodeKeeper
  # Format a result and make it human-readable.
  class Formatter
    class << self
      def format(result)
        title = "Scores:\n\n"
        formatted_result = +title

        result.scores.each_key do |metric|
          result.scores[metric].each do |k, v|
            klass_or_file_key = if metric == :class_length
                                  'Class'
                                else
                                  'Filename'
                                end

            formatted_result.concat(
              <<~EOS
                Metric: #{metric}
                #{klass_or_file_key}: #{k}
                Score: #{v}
                ---
              EOS
            )
          end
        end
        formatted_result
      end
    end
  end
end
