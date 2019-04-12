# frozen_string_literal: true

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
    def initialize(subject, *challenges, **helpers)
      @subject    = subject
      @challenges = challenges

      helpers.each do |method_name, method_block|
        define_singleton_method(method_name) do
          method_block.call
        end
      end
    end

    # Verify the expectation.
    #
    # @param spec [Proc] A spec to compare against the computed actual value.
    #
    # @return [::Spectus::Result::Pass, ::Spectus::Result::Fail] Pass or fail.
    def verify(&spec)
      instance_eval(&spec)
    rescue ::Spectus::Result::Fail => e
      e
    end
  end
end
