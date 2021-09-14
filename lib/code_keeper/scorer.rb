# frozen_string_literal: true

module CodeKeeper
  # Run and store score of metrics.
  class Scorer
    class << self
      def keep(paths)
        result = CodeKeeper::Result.new
        metrics = result.scores.keys
        ruby_file_paths = Finder.new(paths).file_paths
        num_threads = CodeKeeper.config.number_of_threads

        # NOTE: If the configuration says no concurrent execution, the parallel gem is not used.
        # `in_threads: 1` makes 2 threads, a sleep_forever thread and the main thread.
        if num_threads == 1
          ruby_file_paths.each do |path|
            metrics.each { |metric| calculate_score(metric, path, result) }
          end
        else
          Parallel.map(ruby_file_paths, in_threads: num_threads) do |path|
            metrics.each { |metric| calculate_score(metric, path, result) }
          end
        end

        result
      end

      private

      def calculate_score(metric, path, result)
        score = ::CodeKeeper::Metrics::MAPPINGS[metric].new(path).score

        # The class length metric's score has multiple classes.
        score.each do |k, v|
          result.add(metric, k.to_s, v)
        end
      end
    end
  end
end
