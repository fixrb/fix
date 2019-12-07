# frozen_string_literal: true

require 'spectus/expectation_target'
require 'matchi/helper'

module Fix
  # Wraps the target of an expectation.
  #
  # @api private
  #
  class It < ::Spectus::ExpectationTarget
    include ::Matchi::Helper

    # Create a new expection target
    #
    # @param callable [#call] The object to test.
    def initialize(callable, **lets)
      raise unless callable.respond_to?(:call)

      @callable = callable
      @lets     = lets
    end

    private

    def method_missing(name, *args, &block)
      @lets.fetch(name) { super }
    end

    def respond_to_missing?(name, include_private = false)
      @lets.key?(name) || super
    end
  end
end
