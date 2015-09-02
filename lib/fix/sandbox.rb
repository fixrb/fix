module Fix
  # Execute the untested code from the passed challenges.
  #
  # @api private
  #
  class Sandbox
    # Initialize the sandbox class.
    #
    # @param object     [BasicObject] The front object of the test.
    # @param challenges [Array]       The list of challenges to apply.
    def initialize(object, *challenges)
      @object     = object
      @challenges = challenges
    end

    # The actual value.
    #
    # @return [BasicObject] The actual value.
    def actual
      @challenges.inject(@object) do |subject, challenge|
        subject.public_send(challenge.symbol, *challenge.args)
      end
    end
  end
end
