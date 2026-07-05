# frozen_string_literal: true

module CodeKeeper
  # Holds a parsed Ruby source file and the information needed by metrics.
  class SourceFile
    attr_reader :path, :source, :processed_source

    def initialize(path)
      @path = path
      @source = File.read(File.expand_path(path))
      @processed_source = build_processed_source
    rescue Errno::ENOENT
      raise TargetFileNotFoundError, "The target file does not exist. Check the file path: #{path}."
    end

    def ast
      processed_source.ast
    end

    def comments
      processed_source.comments
    end

    def lines
      processed_source.lines
    end

    private

    def build_processed_source
      ::RuboCop::AST::ProcessedSource.new(source, ruby_version, path)
    end

    def ruby_version
      RUBY_VERSION.split('.').first(2).join('.').to_f
    end
  end
end
