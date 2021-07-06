# frozen_string_literal: true

require_relative "code_keeper/version"
require "rubocop"
require 'code_keeper/cyclomatic_complexity'
require 'code_keeper/parser'

module CodeKeeper
  class Error < StandardError; end
  class TargetFileNotFoundError < StandardError; end
end
