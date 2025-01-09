# frozen_string_literal: true

require_relative "doc"
require_relative "dsl"
require_relative "run"
require_relative "error/missing_subject_block"

module Fix
  # A Spec represents a test specification that can be executed as a test suite.
  # It manages the lifecycle of specifications, including:
  # - Building and loading specifications from contexts
  # - Executing specifications in isolation using process forking
  # - Reporting test results
  # - Managing test execution flow and exit status
  #
  # @example Creating and running a simple specification
  #   spec = Fix::Spec.build(:Calculator) do
  #     on(:add, 2, 3) do
  #       it MUST eq 5
  #     end
  #   end
  #   spec.test { Calculator.new }
  #
  # @example Loading and running a registered specification
  #   spec = Fix::Spec.load(:Calculator)
  #   spec.match? { Calculator.new } #=> true
  #
  # @api private
  class Spec
    # Builds a new Spec from a specification block.
    #
    # This method:
    # 1. Creates a new DSL class for the specification
    # 2. Evaluates the specification block in this context
    # 3. Optionally registers the specification under a name
    # 4. Returns a Spec instance ready for testing
    #
    # @param name [Symbol, nil] Optional name to register the specification under
    # @yield Block containing the specification definition using Fix DSL
    # @return [Fix::Spec] A new specification ready for testing
    #
    # @example Building a named specification
    #   Fix::Spec.build(:Calculator) do
    #     on(:add, 2, 3) { it MUST eq 5 }
    #   end
    #
    # @example Building an anonymous specification
    #   Fix::Spec.build(nil) do
    #     it MUST be_positive
    #   end
    #
    # @api private
    def self.build(name, &block)
      klass = ::Class.new(Dsl)
      klass.const_set(:CONTEXTS, [klass])
      klass.instance_eval(&block)
      Doc.const_set(name, klass) unless name.nil?
      new(*klass.const_get(:CONTEXTS))
    end

    # Loads a previously registered specification by name.
    #
    # @param name [Symbol] The name of the registered specification
    # @return [Fix::Spec] The loaded specification
    # @raise [NameError] If the specification name is not found
    #
    # @example Loading a registered specification
    #   Fix::Spec.load(:Calculator)  #=> #<Fix::Spec:...>
    #
    # @api private
    def self.load(name)
      new(*Doc.fetch(name))
    end

    # Initializes a new Spec with given test contexts.
    #
    # The contexts are processed to extract test specifications and
    # randomized to ensure test isolation and catch order dependencies.
    #
    # @param contexts [Array<Fix::Dsl>] List of specification contexts to include
    #
    # @example Creating a specification with multiple contexts
    #   Fix::Spec.new(base_context, admin_context, guest_context)
    def initialize(*contexts)
      @expected = Doc.extract_specifications(*contexts).shuffle
    end

    # Verifies if a subject matches all specifications without exiting.
    #
    # This method is useful for:
    # - Conditional testing where exit on failure is not desired
    # - Integration into larger test suites
    # - Programmatic test result handling
    #
    # @yield Block that returns the subject to test
    # @yieldreturn [Object] The subject to test against specifications
    # @return [Boolean] true if all tests pass, false otherwise
    # @raise [Error::MissingSubjectBlock] If no subject block is provided
    #
    # @example Basic matching
    #   spec.match? { Calculator.new }  #=> true
    #
    # @example Conditional testing
    #   if spec.match? { user_input }
    #     process_valid_input(user_input)
    #   else
    #     handle_invalid_input
    #   end
    #
    # @api public
    def match?(&subject)
      raise Error::MissingSubjectBlock unless subject

      expected.all? { |spec| run_spec(*spec, &subject) }
    end

    # Executes the complete test suite against a subject.
    #
    # This method provides a comprehensive test run that:
    # - Executes all specifications in random order
    # - Runs each test in isolation via process forking
    # - Reports results for each specification
    # - Exits with appropriate status code
    #
    # @yield Block that returns the subject to test
    # @yieldreturn [Object] The subject to test against specifications
    # @return [Boolean] true if all tests pass
    # @raise [SystemExit] Exits with status 1 if any test fails
    # @raise [Error::MissingSubjectBlock] If no subject block is provided
    #
    # @example Basic test execution
    #   spec.test { Calculator.new }
    #
    # @example Testing with dependencies
    #   spec.test {
    #     calc = Calculator.new
    #     calc.precision = :high
    #     calc
    #   }
    #
    # @api public
    def test(&subject)
      match?(&subject) || exit_with_failure
    end

    # Returns a string representation of the specification.
    #
    # @return [String] Human-readable description of the specification
    #
    # @example
    #   spec.to_s #=> "fix [<specification list>]"
    #
    # @api public
    def to_s
      "fix #{expected.inspect}"
    end

    private

    # List of specifications to be tested.
    # Each specification is an array containing:
    # - [0] environment: Fix::Dsl instance for test context
    # - [1] location: String indicating source file and line
    # - [2] requirement: Test requirement (MUST, SHOULD, or MAY)
    # - [3] challenges: Array of test challenges to execute
    #
    # @return [Array<Array>] List of specification arrays
    attr_reader :expected

    # Executes a single specification in an isolated process.
    #
    # @param env [Fix::Dsl] Test environment instance
    # @param location [String] Source location (file:line)
    # @param requirement [Object] Test requirement
    # @param challenges [Array] Test challenges
    # @yield Block returning the subject to test
    # @return [Boolean] true if specification passed
    def run_spec(env, location, requirement, challenges, &subject)
      child_pid = ::Process.fork { execute_spec(env, location, requirement, challenges, &subject) }
      _pid, process_status = ::Process.wait2(child_pid)
      process_status.success?
    end

    # Executes a specification in the current process.
    #
    # @param env [Fix::Dsl] Test environment instance
    # @param location [String] Source location (file:line)
    # @param requirement [Object] Test requirement
    # @param challenges [Array] Test challenges
    # @yield Block returning the subject to test
    # @return [void]
    def execute_spec(env, location, requirement, challenges, &subject)
      result = Run.new(env, requirement, *challenges).test(&subject)
      report_result(location, result)
      exit_with_status(result.passed?)
    end

    # Reports the result of a specification execution.
    #
    # @param location [String] Source location (file:line)
    # @param result [Object] Test execution result
    # @return [void]
    def report_result(location, result)
      puts "#{location} #{result.colored_string}"
    end

    # Exits the process with a failure status.
    #
    # @return [void]
    # @raise [SystemExit] Always exits with status 1
    def exit_with_failure
      ::Kernel.exit(false)
    end

    # Exits the process with the given status.
    #
    # @param status [Boolean] Exit status to use
    # @return [void]
    # @raise [SystemExit] Always exits with provided status
    def exit_with_status(status)
      ::Kernel.exit(status)
    end
  end
end
