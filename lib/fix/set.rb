# frozen_string_literal: true

require "English"

require_relative "doc"
require_relative "run"

module Fix
  # Collection of specifications that can be executed as a test suite.
  #
  # The Set class handles loading, organizing, and executing test specifications.
  # It supports both named and anonymous specifications and provides detailed
  # test reporting.
  #
  # @example Running a named specification
  #   Fix[:Calculator].test { Calculator.new }
  #
  # @example Running an anonymous specification
  #   Fix do
  #     it MUST be_positive
  #   end.test { 42 }
  #
  # @api private
  class Set
    # @return [Array] A list of specifications to be tested
    attr_reader :specs

    class << self
      # Load specifications from a constant name.
      #
      # @param name [String, Symbol] The constant name of the specifications
      # @return [Set] A new Set instance containing the loaded specifications
      # @raise [Fix::Error::SpecificationNotFound] If specification doesn't exist
      #
      # @example
      #   Fix::Set.load(:Calculator)
      #
      # @api public
      def load(name)
        new(*Doc.fetch(name))
      end
    end

    # Initialize a new Set with given contexts.
    #
    # @param contexts [Array<Fix::Dsl>] The list of specification contexts
    #
    # @example
    #   Fix::Set.new(calculator_context)
    def initialize(*contexts)
      @specs = randomize_specs(Doc.extract_specifications(*contexts))
    end

    # Run the test suite against the provided subject.
    #
    # @yield The block of code to be tested
    # @yieldreturn [Object] The result of the code being tested
    # @return [Boolean] true if all tests pass
    # @raise [SystemExit] When tests fail (exit code: 1)
    #
    # @example
    #   set.test { Calculator.new }
    #
    # @api public
    def test(&subject)
      suite_passed?(&subject) || exit_with_failure
    end

    private

    # Randomizes the order of specifications for better isolation
    #
    # @param specifications [Array] The specifications to randomize
    # @return [Array] Randomized specifications
    def randomize_specs(specifications)
      specifications.shuffle
    end

    # Checks if all specifications in the suite passed
    #
    # @yield The subject block to test against
    # @return [Boolean] true if all specs passed
    def suite_passed?(&subject)
      specs.all? { |spec| run_spec(*spec, &subject) }
    end

    # Runs a single specification in a forked process
    #
    # @param env [Fix::Dsl] The test environment
    # @param location [String] The source location of the spec
    # @param requirement [Object] The test requirement
    # @param challenges [Array] The test challenges
    # @yield The subject block to test against
    # @return [Boolean] true if spec passed
    def run_spec(env, location, requirement, challenges, &subject)
      child_pid = ::Process.fork { execute_spec(env, location, requirement, challenges, &subject) }
      _pid, process_status = ::Process.wait2(child_pid)
      process_status.success?
    end

    # Executes a specification in its own process
    #
    # @param env [Fix::Dsl] The test environment
    # @param location [String] The source location of the spec
    # @param requirement [Object] The test requirement
    # @param challenges [Array] The test challenges
    # @yield The subject block to test against
    def execute_spec(env, location, requirement, challenges, &subject)
      result = Run.new(env, requirement, *challenges).test(&subject)
      report_result(location, result)
      exit_with_status(result.passed?)
    end

    # Reports the result of a specification
    #
    # @param location [String] The source location of the spec
    # @param result [Object] The test result
    def report_result(location, result)
      puts "#{location} #{result.colored_string}"
    end

    # Exits the process with a failure status
    #
    # @return [void]
    # @raise [SystemExit] Always
    def exit_with_failure
      ::Kernel.exit(false)
    end

    # Exits the process with the given status
    #
    # @param status [Boolean] The exit status
    # @return [void]
    # @raise [SystemExit] Always
    def exit_with_status(status)
      ::Kernel.exit(status)
    end
  end
end
