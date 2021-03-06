# frozen_string_literal: true

require_relative "code_keeper/version"
require "rubocop"
require 'code_keeper/parser'
require 'code_keeper/finder'
require 'code_keeper/cli'
require 'code_keeper/formatter'
require 'code_keeper/config'
require 'code_keeper/scorer'
require 'code_keeper/result'
require 'code_keeper/metrics'
require 'code_keeper/metrics/abc_metric'
require 'code_keeper/metrics/cyclomatic_complexity'
require 'code_keeper/metrics/class_length'

module CodeKeeper
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end

  # Raised when a file does not exist
  class TargetFileNotFoundError < StandardError
    def initialize(path)
      msg = "The target file does not exist. Check the file path: #{path}."
      super(msg)
    end
  end
end
