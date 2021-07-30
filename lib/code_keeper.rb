# frozen_string_literal: true

require_relative "code_keeper/version"
require "rubocop"
require 'code_keeper/cyclomatic_complexity'
require 'code_keeper/parser'
require 'code_keeper/finder'
require 'code_keeper/cli'
require 'code_keeper/formatter'

module CodeKeeper
  class Error < StandardError; end

  # Raised when a file does not exist
  class TargetFileNotFoundError < StandardError
    def initialize(path)
      msg = "The target file does not exist. Check the file path: #{path}."
      super(msg)
    end
  end
end
