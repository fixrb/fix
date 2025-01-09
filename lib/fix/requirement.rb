# frozen_string_literal: true

require "spectus/requirement/optional"
require "spectus/requirement/recommended"
require "spectus/requirement/required"

module Fix
  # Implements requirement levels as defined in RFC 2119.
  # Provides methods for specifying different levels of requirements
  # in test specifications: MUST, SHOULD, and MAY.
  #
  # @api private
  module Requirement
    # rubocop:disable Naming/MethodName

    # This method means that the definition is an absolute requirement of the
    # specification.
    #
    # @example Test exact equality
    #   it MUST eq(42)
    #
    # @example Test type matching
    #   it MUST be_an_instance_of(User)
    #
    # @example Test state changes
    #   it MUST change(user, :status).from("pending").to("active")
    #
    # @param matcher [#match?] The matcher that defines the required condition
    # @return [::Spectus::Requirement::Required] An absolute requirement level instance
    #
    # @api public
    def MUST(matcher)
      ::Spectus::Requirement::Required.new(negate: false, matcher:)
    end

    # This method means that the definition is an absolute prohibition of the
    # specification.
    #
    # @example Test prohibited state
    #   it MUST_NOT be_nil
    #
    # @example Test prohibited type
    #   it MUST_NOT be_a_kind_of(AdminUser)
    #
    # @example Test prohibited exception
    #   it MUST_NOT raise_exception(SecurityError)
    #
    # @param matcher [#match?] The matcher that defines the prohibited condition
    # @return [::Spectus::Requirement::Required] An absolute prohibition level instance
    #
    # @api public
    def MUST_NOT(matcher)
      ::Spectus::Requirement::Required.new(negate: true, matcher:)
    end

    # This method means that there may exist valid reasons in particular
    # circumstances to ignore this requirement, but the implications must be
    # understood and carefully weighed.
    #
    # @example Test numeric boundaries
    #   it SHOULD be_within(0.1).of(expected_value)
    #
    # @example Test pattern matching
    #   it SHOULD match(/^[A-Z][a-z]+$/)
    #
    # @example Test custom condition
    #   it SHOULD satisfy { |obj| obj.valid? && obj.complete? }
    #
    # @param matcher [#match?] The matcher that defines the recommended condition
    # @return [::Spectus::Requirement::Recommended] A recommended requirement level instance
    #
    # @api public
    def SHOULD(matcher)
      ::Spectus::Requirement::Recommended.new(negate: false, matcher:)
    end

    # This method means that there may exist valid reasons in particular
    # circumstances when the behavior is acceptable, but the implications should be
    # understood and weighed carefully.
    #
    # @example Test state changes to avoid
    #   it SHOULD_NOT change(object, :state)
    #
    # @param matcher [#match?] The matcher that defines the discouraged condition
    # @return [::Spectus::Requirement::Recommended] A discouraged requirement level instance
    #
    # @api public
    def SHOULD_NOT(matcher)
      ::Spectus::Requirement::Recommended.new(negate: true, matcher:)
    end

    # This method means that the item is truly optional. Implementations may
    # include this feature if it enhances their product, and must be prepared to
    # interoperate with implementations that include or omit this feature.
    #
    # @example Test optional functionality
    #   it MAY respond_to(:cache_key)
    #
    # @example Test optional state
    #   it MAY be_frozen
    #
    # @param matcher [#match?] The matcher that defines the optional condition
    # @return [::Spectus::Requirement::Optional] An optional requirement level instance
    #
    # @api public
    def MAY(matcher)
      ::Spectus::Requirement::Optional.new(negate: false, matcher:)
    end

    # rubocop:enable Naming/MethodName
  end
end
