require 'spectus/expectation_target'

module Fix
  # Wraps the target of an expectation.
  #
  # @api private
  #
  class It < Spectus::ExpectationTarget
    # Create a new expection target
    #
    # @param subject    [BasicObject] The front object.
    # @param challenges [Array]       The list of challenges.
    def initialize(subject, *challenges)
      @subject    = subject
      @challenges = challenges
    end
  end
end
