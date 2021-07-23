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
  class TargetFileNotFoundError < StandardError; end
end
