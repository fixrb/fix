# frozen_string_literal: true

require "expresenter/fail"

module Fix
  module Requirement
    # Represents a requirement entry in a specification,
    # with its context and source location.
    #
    # @api private
    class Definition
      # @return [Fix::Dsl] The environment of this requirement
      attr_reader :environment

      # @return [Spectus::Requirement::Base] The requirement (MUST/SHOULD/MAY)
      attr_reader :requirement

      # @return [String] File path and line number where this requirement is defined
      attr_reader :location

      # @return [Array]
      attr_reader :challenges

      def initialize(environment, requirement, location, *challenges)
        @environment = environment
        @requirement = requirement
        @location = location
        @challenges = challenges

        freeze
      end

      def test(&subject)
        requirement.call { actual_value(&subject) }
      rescue ::Expresenter::Fail => e
        e
      end

      def to_s
        "#{requirement} at #{location}"
      end

      private

      def actual_value(&subject)
        initial_value = environment.instance_eval(&subject)

        challenges.inject(initial_value) do |obj, challenge|
          challenge.to(obj).call
        end
      end
    end
  end
end
