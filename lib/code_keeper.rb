# frozen_string_literal: true

require_relative "code_keeper/version"
require "rubocop"
require 'code_keeper/cyclomatic_complexity'

module CodeKeeper
  class Error < StandardError; end
end
