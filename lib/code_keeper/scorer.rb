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

        return keep_legacy(ruby_file_paths, metrics, result, num_threads) if CodeKeeper.config.metrics_engine == :legacy

        measurements = measure_files(ruby_file_paths, metrics, num_threads)
        measurements.each { |measurement| result.add_measurement(measurement) }

        result
      end

      private

      def keep_legacy(ruby_file_paths, metrics, result, num_threads)
        if num_threads == 1
          ruby_file_paths.each do |path|
            metrics.each { |metric| calculate_legacy_score(metric, path, result) }
          end
        else
          legacy_scores = Parallel.map(ruby_file_paths, in_threads: num_threads) do |path|
            metrics.each_with_object([]) do |metric, scores|
              scores << [metric, ::CodeKeeper::Metrics::MAPPINGS[metric].new(path, engine: :legacy).score]
            end
          end

          legacy_scores.flatten(1).each do |metric, score|
            add_score(metric, score, result)
          end
        end

        result
      end

      def measure_files(ruby_file_paths, metrics, num_threads)
        if num_threads == 1
          ruby_file_paths.flat_map { |path| measure_file(path, metrics) }
        else
          Parallel.map(ruby_file_paths, in_threads: num_threads) do |path|
            measure_file(path, metrics)
          end.flatten
        end
      end

      def measure_file(path, metrics)
        source_file = Parser.source_file(path)

        metrics.flat_map do |metric|
          ::CodeKeeper::Metrics::MAPPINGS[metric].measure(source_file)
        end
      end

      def calculate_legacy_score(metric, path, result)
        score = ::CodeKeeper::Metrics::MAPPINGS[metric].new(path, engine: :legacy).score

        add_score(metric, score, result)
      end

      def add_score(metric, score, result)
        score.each do |k, v|
          result.add(metric, k.to_s, v)
        end
      end
    end
  end
end
