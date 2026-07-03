# frozen_string_literal: true

module CodeKeeper
  # Runs metrics and builds the metric report.
  class Scorer
    class << self
      def keep(paths)
        metrics = CodeKeeper.config.metrics.uniq
        ruby_file_paths = Finder.new(paths).file_paths
        num_threads = CodeKeeper.config.number_of_threads

        MetricReport.new(measure_files(ruby_file_paths, metrics, num_threads))
      end

      private

      def measure_files(ruby_file_paths, metrics, num_threads)
        if num_threads == 1 || ruby_file_paths.one?
          ruby_file_paths.flat_map { |path| measure_file(path, metrics) }
        else
          parallel_map(ruby_file_paths, num_threads) do |path|
            measure_file(path, metrics)
          end.flatten
        end
      end

      def parallel_map(items, num_threads)
        worker_count = [[num_threads.to_i, 1].max, items.size].min
        jobs = Queue.new
        results = Array.new(items.size)

        items.each_with_index { |item, index| jobs << [index, item] }

        threads = worker_count.times.map do
          Thread.new do
            loop do
              begin
                index, item = jobs.pop(true)
              rescue ThreadError
                break
              end

              results[index] = yield item
            end
          end
        end

        threads.each(&:value)
        results
      end

      def measure_file(path, metrics)
        source_file = SourceFile.new(path)

        metrics.flat_map do |metric|
          ::CodeKeeper::Metrics::MAPPINGS[metric].measure(source_file)
        end
      end
    end
  end
end
