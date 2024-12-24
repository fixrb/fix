# frozen_string_literal: true

require "English"

require_relative "doc"
require_relative "run"

module Fix
  # Collection of specifications.
  #
  # @api private
  class Set
    # @return [Array] A list of specifications.
    attr_reader :specs

    # Load specifications from a constant name.
    #
    # @param name [String, Symbol] The constant name of the specifications.
    # @return [Set] A new Set instance containing the loaded specifications.
    #
    # @api public
    def self.load(name)
      new(*Doc.fetch(name))
    end

    # Initialize a new Set with given contexts.
    #
    # @param contexts [Array<::Fix::Dsl>] The list of contexts document.
    def initialize(*contexts)
      @specs = Doc.specs(*contexts).shuffle
    end

    # Run the test suite against the provided subject.
    #
    # @yield The block of code to be tested
    # @yieldreturn [Object] The result of the code being tested
    # @return [Boolean] true if all tests pass, exits with false otherwise
    # @raise [::SystemExit] The test set failed!
    #
    # @api public
    def test(&)
      suite_passed?(&) || ::Kernel.exit(false)
    end

    private

    def suite_passed?(&subject)
      specs.all? { |spec| run_spec(*spec, &subject) }
    end

    def run_spec(env, location, requirement, challenges, &subject)
      ::Process.fork { lab(env, location, requirement, challenges, &subject) }
      ::Process.wait
      $CHILD_STATUS.success?
    end

    def lab(env, location, requirement, challenges, &)
      result = Run.new(env, requirement, *challenges).test(&)
      report!(location, result)
      ::Kernel.exit(result.passed?)
    end

    def report!(path, result)
      puts "#{path} #{result.colored_string}"
    end
  end
end
