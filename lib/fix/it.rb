require 'spectus/expectation_target'
require 'spectus/matchers'

module Fix
  # Wraps the target of an expectation.
  #
  # @api private
  #
  class It < Spectus::ExpectationTarget
    include ::Spectus::Matchers

    # Create a new expection target
    #
    # @param subject    [BasicObject] The front object.
    # @param challenges [Array]       The list of challenges.
    # @param helpers    [Hash]        The list of helpers.
    def initialize(subject, challenges, helpers)
      @subject    = subject
      @challenges = challenges
      @helpers    = helpers
    end

    # @!attribute [r] helpers
    #
    # @return [Hash] The list of helpers.
    attr_reader :helpers

    # Verify the expectation.
    #
    # @param spec [Proc] A spec to compare against the computed actual value.
    #
    # @return [::Spectus::Result::Pass, ::Spectus::Result::Fail] Pass or fail.
    def verify(&spec)
      instance_eval(&spec)
    rescue ::Spectus::Result::Fail => f
      f
    end
  end
end
