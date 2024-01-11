# frozen_string_literal: true

require "matchi"

module Fix
  # Collection of expectation matchers.
  #
  # @api private
  module Matcher
    # Equivalence matcher
    #
    # @example
    #   matcher = eq("foo")
    #   matcher.matches? { "foo" } # => true
    #   matcher.matches? { "bar" } # => false
    #
    # @param expected [#eql?] An expected equivalent object.
    #
    # @return [#matches?] An equivalence matcher.
    #
    # @api public
    def eq(expected)
      ::Matchi::Eq.new(expected)
    end

    alias eql eq

    # Identity matcher
    #
    # @example
    #   object = "foo"
    #   matcher = be(object)
    #   matcher.matches? { object } # => true
    #   matcher.matches? { "foo" } # => false
    #
    # @param expected [#equal?] The expected identical object.
    #
    # @return [#matches?] An identity matcher.
    #
    # @api public
    def be(expected)
      ::Matchi::Be.new(expected)
    end

    alias equal be

    # Comparisons matcher
    #
    # @example
    #   matcher = be_within(1).of(41)
    #   matcher.matches? { 42 } # => true
    #   matcher.matches? { 43 } # => false
    #
    # @param delta [Numeric] A numeric value.
    #
    # @return [#matches?] A comparison matcher.
    #
    # @api public
    def be_within(delta)
      ::Matchi::BeWithin.new(delta)
    end

    # Regular expressions matcher
    #
    # @example
    #   matcher = match(/^foo$/)
    #   matcher.matches? { "foo" } # => true
    #   matcher.matches? { "bar" } # => false
    #
    # @param expected [#match] A regular expression.
    #
    # @return [#matches?] A regular expression matcher.
    #
    # @api public
    def match(expected)
      ::Matchi::Match.new(expected)
    end

    # Expecting errors matcher
    #
    # @example
    #   matcher = raise_exception(NameError)
    #   matcher.matches? { Boom } # => true
    #   matcher.matches? { true } # => false
    #
    # @param expected [Exception, #to_s] The expected exception name.
    #
    # @return [#matches?] An error matcher.
    #
    # @api public
    def raise_exception(expected)
      ::Matchi::RaiseException.new(expected)
    end

    # True matcher
    #
    # @example
    #   matcher = be_true
    #   matcher.matches? { true } # => true
    #   matcher.matches? { false } # => false
    #   matcher.matches? { nil } # => false
    #   matcher.matches? { 4 } # => false
    #
    # @return [#matches?] A `true` matcher.
    #
    # @api public
    def be_true
      be(true)
    end

    # False matcher
    #
    # @example
    #   matcher = be_false
    #   matcher.matches? { false } # => true
    #   matcher.matches? { true } # => false
    #   matcher.matches? { nil } # => false
    #   matcher.matches? { 4 } # => false
    #
    # @return [#matches?] A `false` matcher.
    #
    # @api public
    def be_false
      be(false)
    end

    # Nil matcher
    #
    # @example
    #   matcher = be_nil
    #   matcher.matches? { nil } # => true
    #   matcher.matches? { false } # => false
    #   matcher.matches? { true } # => false
    #   matcher.matches? { 4 } # => false
    #
    # @return [#matches?] A `nil` matcher.
    #
    # @api public
    def be_nil
      be(nil)
    end

    # Type/class matcher
    #
    # @example
    #   matcher = be_an_instance_of(String)
    #   matcher.matches? { "foo" } # => true
    #   matcher.matches? { 4 } # => false
    #
    # @param expected [Class, #to_s] The expected class name.
    #
    # @return [#matches?] A type/class matcher.
    #
    # @api public
    def be_an_instance_of(expected)
      ::Matchi::BeAnInstanceOf.new(expected)
    end

    # Change matcher
    #
    # @example
    #   object = []
    #   matcher = change(object, :length).by(1)
    #   matcher.matches? { object << 1 } # => true
    #
    #   object = []
    #   matcher = change(object, :length).by_at_least(1)
    #   matcher.matches? { object << 1 } # => true
    #
    #   object = []
    #   matcher = change(object, :length).by_at_most(1)
    #   matcher.matches? { object << 1 } # => true
    #
    #   object = "foo"
    #   matcher = change(object, :to_s).from("foo").to("FOO")
    #   matcher.matches? { object.upcase! } # => true
    #
    #   object = "foo"
    #   matcher = change(object, :to_s).to("FOO")
    #   matcher.matches? { object.upcase! } # => true
    #
    # @param object [#object_id]  An object.
    # @param method [Symbol]      The name of a method.
    #
    # @return [#matches?] A change matcher.
    #
    # @api public
    def change(object, method, ...)
      ::Matchi::Change.new(object, method, ...)
    end

    # Satisfy matcher
    #
    # @example
    #   matcher = satisfy { |value| value == 42 }
    #   matcher.matches? { 42 } # => true
    #
    # @param expected [Proc] A block of code.
    #
    # @return [#matches?] A satisfy matcher.
    #
    # @api public
    def satisfy(&expected)
      ::Matchi::Satisfy.new(&expected)
    end

    private

    # Predicate matcher, or default method missing behavior.
    #
    # @example Empty predicate matcher
    #   matcher = be_empty
    #   matcher.matches? { [] } # => true
    #   matcher.matches? { [4] } # => false
    def method_missing(name, ...)
      return super unless predicate_matcher_name?(name)

      ::Matchi::Predicate.new(name, ...)
    end

    # :nocov:

    # Hook method to return whether the obj can respond to id method or not.
    def respond_to_missing?(name, include_private = false)
      predicate_matcher_name?(name) || super
    end

    # :nocov:

    # Predicate matcher name detector.
    #
    # @param name [Array, Symbol] The name of a potential predicate matcher.
    #
    # @return [Boolean] Indicates if it is a predicate matcher name or not.
    def predicate_matcher_name?(name)
      name.start_with?("be_", "have_") && !name.end_with?("!", "?")
    end
  end
end
