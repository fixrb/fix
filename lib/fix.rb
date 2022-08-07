# frozen_string_literal: true

require_relative File.join("fix", "set")

require_relative "kernel"

# Namespace for the Fix framework.
#
# @api public
module Fix
  # Test a built specification.
  #
  # @example Run _Answer_ specification against `42`.
  #   Fix[:Answer].test(42)
  #
  # @param name [String, Symbol] The constant name of the specifications.
  #
  # @return [::Fix::Test] The specification document.
  def self.[](name)
    ::Fix::Set.load(name)
  end
end
