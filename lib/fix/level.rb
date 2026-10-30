# frozen_string_literal: true

require "spectus"

module Fix
  # The requirement levels of RFC 2119, as the words of a specification:
  # each one turns a matcher into a `Spectus::Requirement`. A MAY has no
  # negative form.
  module Level
    # @param matcher [#match?] the matcher
    # @return [Spectus::Requirement] an absolute requirement
    def MUST(matcher) # rubocop:disable Naming/MethodName
      ::Spectus.must(matcher)
    end

    # @param matcher [#match?] the matcher
    # @return [Spectus::Requirement] an absolute prohibition
    def MUST_NOT(matcher) # rubocop:disable Naming/MethodName
      ::Spectus.must_not(matcher)
    end

    # @param matcher [#match?] the matcher
    # @return [Spectus::Requirement] a recommendation
    def SHOULD(matcher) # rubocop:disable Naming/MethodName
      ::Spectus.should(matcher)
    end

    # @param matcher [#match?] the matcher
    # @return [Spectus::Requirement] a negated recommendation
    def SHOULD_NOT(matcher) # rubocop:disable Naming/MethodName
      ::Spectus.should_not(matcher)
    end

    # @param matcher [#match?] the matcher
    # @return [Spectus::Requirement] an option
    def MAY(matcher) # rubocop:disable Naming/MethodName
      ::Spectus.may(matcher)
    end
  end
end
