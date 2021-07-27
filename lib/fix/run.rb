# frozen_string_literal: true

require "expresenter/fail"

module Fix
  # Run class.
  #
  # @api private
  class Run
    # @return [::Fix::Dsl] A context instance.
    attr_reader :environment

    # @return [::Spectus::Requirement::Base] An expectation.
    attr_reader :requirement

    # @return [Array<::Defi::Challenge>] A list of challenges.
    attr_reader :challenges

    # @param environment  [::Fix::Dsl]                    A context instance.
    # @param requirement  [::Spectus::Requirement::Base]  An expectation.
    # @param challenges   [Array<::Defi::Challenge>]      A list of challenges.
    def initialize(environment, requirement, *challenges)
      @environment = environment
      @requirement = requirement
      @challenges  = challenges
    end

    # Verify if the object checks the condition.
    #
    # @param subject [Proc] The block of code to be tested.
    #
    # @raise [::Expresenter::Fail] A failed spec exception.
    # @return [::Expresenter::Pass] A passed spec instance.
    #
    # @see https://github.com/fixrb/expresenter
    def against(&subject)
      requirement.call { actual_value(&subject) }
    rescue ::Expresenter::Fail => e
      e
    end

    private

    # The test's actual value.
    #
    # @param subject [Proc] The block of code to be tested.
    #
    # @return [#object_id] The actual value to be tested.
    def actual_value(&subject)
      challenges.inject(environment.instance_eval(&subject)) do |obj, challenge|
        challenge.to(obj).call
      end
    end
  end
end
