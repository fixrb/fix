# frozen_string_literal: true

require "expresenter/fail"

module Fix
  # Executes a test specification by running a subject against a set of challenges
  # and requirements.
  #
  # The Run class orchestrates test execution by:
  # 1. Evaluating the test subject in the proper environment
  # 2. Applying a series of method challenges to the result
  # 3. Verifying the final value against the requirement
  #
  # @example Running a simple test
  #   run = Run.new(env, requirement)
  #   run.test { MyClass.new }
  #
  # @example Running with method challenges
  #   run = Run.new(env, requirement, challenge1, challenge2)
  #   run.test { MyClass.new }  # Will call methods defined in challenges
  #
  # @api private
  class Run
    # The test environment containing defined variables and methods
    # @return [::Fix::Dsl] A context instance
    attr_reader :environment

    # The specification requirement to validate against
    # @return [::Spectus::Requirement::Base] An expectation
    attr_reader :requirement

    # The list of method calls to apply to the subject
    # @return [Array<::Defi::Method>] A list of challenges
    attr_reader :challenges

    # Initializes a new test run with the given environment and challenges.
    #
    # @param environment [::Fix::Dsl] Context instance with test setup
    # @param requirement [::Spectus::Requirement::Base] Expectation to verify
    # @param challenges [Array<::Defi::Method>] Method calls to apply
    #
    # @example
    #   Run.new(test_env, must_be_positive, increment_method)
    def initialize(environment, requirement, *challenges)
      @environment = environment
      @requirement = requirement
      @challenges = challenges
    end

    # Verifies if the subject meets the requirement after applying all challenges.
    #
    # @param subject [Proc] The block of code to be tested
    #
    # @raise [::Expresenter::Fail] When the test specification fails
    # @return [::Expresenter::Pass] When the test specification passes
    #
    # @example Basic testing
    #   run.test { 42 }
    #
    # @example Testing with subject modification
    #   run.test { User.new(name: "John") }
    #
    # @see https://github.com/fixrb/expresenter
    def test(&subject)
      requirement.call { actual_value(&subject) }
    rescue ::Expresenter::Fail => e
      e
    end

    private

    # Computes the final value to test by applying all challenges to the subject.
    #
    # @param subject [Proc] The initial test subject
    # @return [#object_id] The final value after applying all challenges
    #
    # @example Internal process
    #   # If challenges are [:upcase, :reverse]
    #   # and subject returns "hello"
    #   # actual_value will return "OLLEH"
    def actual_value(&subject)
      initial_value = environment.instance_eval(&subject)
      challenges.inject(initial_value) do |obj, challenge|
        challenge.to(obj).call
      end
    end
  end
end
