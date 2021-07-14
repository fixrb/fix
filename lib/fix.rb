# frozen_string_literal: true

require_relative File.join("fix", "test")

require_relative "kernel"

# Namespace for the Fix framework.
module Fix
  # Test a built specification.
  #
  # @example Run _Answer_ specification against `42`.
  #   Fix[:Answer].call(42)
  #
  # @example Test _Answer_ specification against `42`.
  #   Fix[:Answer].matches? { 42 }
  #
  # @param name [String, Symbol] The name of the specification document.
  #
  # @return [::Fix::Dsl] The specification document.
  def self.[](name)
    Test.new(name)
  end
end
