# frozen_string_literal: true

module CodeKeeper
  # Find ruby files and manage the list of files.
  class Finder
    attr_reader :file_paths

    def initialize(paths)
      @file_paths = search_recursively(paths.uniq).map do |path|
        raise ::CodeKeeper::TargetFileNotFoundError.new(path) unless File.exist?(path)

        path if FileTest.file?(path) && File.extname(path) == '.rb'
      end.compact
    end

    private

    def search_recursively(file_or_dir_paths)
      file_or_dir_paths.each do |edge|
        if FileTest.file?(edge)
          file_or_dir_paths << edge unless file_or_dir_paths.include?(edge)
        else
          Dir.glob(("#{edge}/**/*")).each do |path|
            file_or_dir_paths << path unless file_or_dir_paths.include?(path)
          end
        end
      end
    end
  end
end
