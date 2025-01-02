# frozen_string_literal: true

require_relative "doc"
require_relative "run"
require_relative "error/missing_subject_block"

module Fix
  # Collection of specifications that can be executed as a test suite.
  #
  # The Set class is a central component in Fix's architecture that handles:
  # - Loading and organizing test specifications
  # - Managing test execution and isolation
  # - Reporting test results
  # - Handling process management for test isolation
  #
  # It supports both named specifications (loaded via Fix[name]) and anonymous
  # specifications (created directly via Fix blocks).
  #
  # @example Running a simple named specification
  #   Fix[:Calculator].test { Calculator.new }
  #
  # @example Running a complex specification with multiple contexts
  #   Fix[:UserSystem] do
  #     with(role: "admin") do
  #       on :access?, :settings do
  #         it MUST be_true
  #       end
  #     end
  #
  #     with(role: "guest") do
  #       on :access?, :settings do
  #         it MUST be_false
  #       end
  #     end
  #   end.test { UserSystem.new(role:) }
  #
  # @example Using match? for conditional testing
  #   if Fix[:EmailValidator].match? { email }
  #     puts "Email is valid"
  #   end
  #
  # @api private
  class Set
    # List of specifications to be tested.
    # Each specification is an array containing:
    # - The test environment
    # - The source location (file:line)
    # - The requirement (MUST, SHOULD, or MAY)
    # - The challenges to apply
    #
    # @return [Array] List of specifications
    attr_reader :expected

    class << self
      # Loads specifications from a registered constant name.
      #
      # This method retrieves previously registered specifications and creates
      # a new Set instance ready for testing. It's typically used in conjunction
      # with Fix[name] syntax.
      #
      # @param name [String, Symbol] The constant name of the specifications
      # @return [Set] A new Set instance containing the loaded specifications
      # @raise [Fix::Error::SpecificationNotFound] If specification doesn't exist
      #
      # @example Loading a named specification
      #   Fix::Set.load(:Calculator)
      #
      # @example Loading and testing in one go
      #   Fix::Set.load(:EmailValidator).test { email }
      #
      # @api public
      def load(name)
        new(*Doc.fetch(name))
      end
    end

    # Initialize a new Set with the given contexts.
    #
    # @param contexts [Array<Fix::Dsl>] List of specification contexts
    #
    # @example Creating a set with a single context
    #   Fix::Set.new(calculator_context)
    #
    # @example Creating a set with multiple contexts
    #   Fix::Set.new(base_context, admin_context, guest_context)
    def initialize(*contexts)
      @expected = randomize_specs(Doc.extract_specifications(*contexts))
    end

    # Checks if the subject matches all specifications without exiting.
    #
    # Unlike #test, this method:
    # - Returns a boolean instead of exiting
    # - Can be used in conditional logic
    #
    # @yield The block of code to be tested
    # @yieldreturn [Object] The result of the code being tested
    # @return [Boolean] true if all tests pass, false otherwise
    #
    # @example Basic usage
    #   set.match? { Calculator.new } #=> true
    #
    # @example Conditional usage
    #   if set.match? { user_input }
    #     save_to_database(user_input)
    #   end
    #
    # @api public
    def match?(&subject)
      raise Error::MissingSubjectBlock unless subject

      expected.all? { |spec| run_spec(*spec, &subject) }
    end

    # Runs the test suite against the provided subject.
    #
    # This method:
    # - Executes all specifications in random order
    # - Runs each test in isolation using process forking
    # - Reports results for each specification
    # - Exits with failure if any test fails
    #
    # @yield The block of code to be tested
    # @yieldreturn [Object] The result of the code being tested
    # @return [Boolean] true if all tests pass
    # @raise [SystemExit] When any test fails (exit code: 1)
    #
    # @example Basic usage
    #   set.test { Calculator.new }
    #
    # @example Testing with parameters
    #   set.test { Game.new(south_variant:, north_variant:) }
    #
    # @api public
    def test(&subject)
      match?(&subject) || exit_with_failure
    end

    # Returns a string representing the matcher.
    #
    # @return [String] a human-readable description of the matcher
    #
    # @api public
    def to_s
      "fix #{expected.inspect}"
    end

    private

    # Randomizes the order of specifications for better isolation
    #
    # @param specifications [Array] The specifications to randomize
    # @return [Array] Randomized specifications
    def randomize_specs(specifications)
      specifications.shuffle
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
