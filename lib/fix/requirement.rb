# frozen_string_literal: true

require "spectus/requirement/optional"
require "spectus/requirement/recommended"
require "spectus/requirement/required"

module Fix
  # Collection of expectation matchers.
  #
  # @api private
  module Requirement
    # rubocop:disable Naming/MethodName

    # This method mean that the definition is an absolute requirement of the
    # specification.
    #
    # @param matcher [#matches?] The matcher.
    #
    # @return [Requirement::Required] An absolute requirement level instance.
    #
    # @api public
    def MUST(matcher)
      ::Spectus::Requirement::Required.new(
        isolate: false,
        negate:  false,
        matcher: matcher
      )
    end

    # @see MUST
    #
    # @api public
    def MUST!(matcher)
      ::Spectus::Requirement::Required.new(
        isolate: true,
        negate:  false,
        matcher: matcher
      )
    end

    # This method mean that the definition is an absolute prohibition of the specification.
    #
    # @param matcher [#matches?] The matcher.
    #
    # @return [Requirement::Required] An absolute prohibition level instance.
    #
    # @api public
    def MUST_NOT(matcher)
      ::Spectus::Requirement::Required.new(
        isolate: false,
        negate:  true,
        matcher: matcher
      )
    end

    # @see MUST_NOT
    #
    # @api public
    def MUST_NOT!(matcher)
      ::Spectus::Requirement::Required.new(
        isolate: true,
        negate:  true,
        matcher: matcher
      )
    end

    # This method mean that there may exist valid reasons in particular
    # circumstances to ignore a particular item, but the full implications must be
    # understood and carefully weighed before choosing a different course.
    #
    # @param matcher [#matches?] The matcher.
    #
    # @return [Requirement::Recommended] A recommended requirement level instance.
    #
    # @api public
    def SHOULD(matcher)
      ::Spectus::Requirement::Recommended.new(
        isolate: false,
        negate:  false,
        matcher: matcher
      )
    end

    # @see SHOULD
    #
    # @api public
    def SHOULD!(matcher)
      ::Spectus::Requirement::Recommended.new(
        isolate: true,
        negate:  false,
        matcher: matcher
      )
    end

    # This method mean that there may exist valid reasons in particular
    # circumstances when the particular behavior is acceptable or even useful, but
    # the full implications should be understood and the case carefully weighed
    # before implementing any behavior described with this label.
    #
    # @param matcher [#matches?] The matcher.
    #
    # @return [Requirement::Recommended] A not recommended requirement level
    #   instance.
    #
    # @api public
    def SHOULD_NOT(matcher)
      ::Spectus::Requirement::Recommended.new(
        isolate: false,
        negate:  true,
        matcher: matcher
      )
    end

    # @see SHOULD_NOT
    #
    # @api public
    def SHOULD_NOT!(matcher)
      ::Spectus::Requirement::Recommended.new(
        isolate: true,
        negate:  true,
        matcher: matcher
      )
    end

    # This method mean that an item is truly optional.
    # One vendor may choose to include the item because a particular marketplace
    # requires it or because the vendor feels that it enhances the product while
    # another vendor may omit the same item. An implementation which does not
    # include a particular option must be prepared to interoperate with another
    # implementation which does include the option, though perhaps with reduced
    # functionality. In the same vein an implementation which does include a
    # particular option must be prepared to interoperate with another
    # implementation which does not include the option (except, of course, for the
    # feature the option provides).
    #
    # @param matcher [#matches?] The matcher.
    #
    # @return [Requirement::Optional] An optional requirement level instance.
    #
    # @api public
    def MAY(matcher)
      ::Spectus::Requirement::Optional.new(
        isolate: false,
        negate:  false,
        matcher: matcher
      )
    end

    # @see MAY
    #
    # @api public
    def MAY!(matcher)
      ::Spectus::Requirement::Optional.new(
        isolate: true,
        negate:  false,
        matcher: matcher
      )
    end

    # rubocop:enable Naming/MethodName
  end
end
