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
    #   matcher.match? { "foo" } # => true
    #   matcher.match? { "bar" } # => false
    #
    # @param expected [#eql?] An expected equivalent object.
    #
    # @return [#match?] An equivalence matcher.
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
    #   matcher.match? { object } # => true
    #   matcher.match? { "foo" } # => false
    #
    # @param expected [#equal?] The expected identical object.
    #
    # @return [#match?] An identity matcher.
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
    #   matcher.match? { 42 } # => true
    #   matcher.match? { 43 } # => false
    #
    # @param delta [Numeric] A numeric value.
    #
    # @return [#match?] A comparison matcher.
    #
    # @api public
    def be_within(delta)
      ::Matchi::BeWithin.new(delta)
    end

    # Regular expressions matcher
    #
    # @example
    #   matcher = match(/^foo$/)
    #   matcher.match? { "foo" } # => true
    #   matcher.match? { "bar" } # => false
    #
    # @param expected [#match] A regular expression.
    #
    # @return [#match?] A regular expression matcher.
    #
    # @api public
    def match(expected)
      ::Matchi::Match.new(expected)
    end

    # Expecting errors matcher
    #
    # @example
    #   matcher = raise_exception(NameError)
    #   matcher.match? { Boom } # => true
    #   matcher.match? { true } # => false
    #
    # @param expected [Exception, #to_s] The expected exception name.
    #
    # @return [#match?] An error matcher.
    #
    # @api public
    def raise_exception(expected)
      ::Matchi::RaiseException.new(expected)
    end

    # True matcher
    #
    # @example
    #   matcher = be_true
    #   matcher.match? { true } # => true
    #   matcher.match? { false } # => false
    #   matcher.match? { nil } # => false
    #   matcher.match? { 4 } # => false
    #
    # @return [#match?] A `true` matcher.
    #
    # @api public
    def be_true
      be(true)
    end

    # False matcher
    #
    # @example
    #   matcher = be_false
    #   matcher.match? { false } # => true
    #   matcher.match? { true } # => false
    #   matcher.match? { nil } # => false
    #   matcher.match? { 4 } # => false
    #
    # @return [#match?] A `false` matcher.
    #
    # @api public
    def be_false
      be(false)
    end

    # Nil matcher
    #
    # @example
    #   matcher = be_nil
    #   matcher.match? { nil } # => true
    #   matcher.match? { false } # => false
    #   matcher.match? { true } # => false
    #   matcher.match? { 4 } # => false
    #
    # @return [#match?] A `nil` matcher.
    #
    # @api public
    def be_nil
      be(nil)
    end

    # Type/class matcher
    #
    # @example
    #   matcher = be_an_instance_of(String)
    #   matcher.match? { "foo" } # => true
    #   matcher.match? { 4 } # => false
    #
    # @param expected [Class, #to_s] The expected class name.
    #
    # @return [#match?] A type/class matcher.
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
    #   matcher.match? { object << 1 } # => true
    #
    #   object = []
    #   matcher = change(object, :length).by_at_least(1)
    #   matcher.match? { object << 1 } # => true
    #
    #   object = []
    #   matcher = change(object, :length).by_at_most(1)
    #   matcher.match? { object << 1 } # => true
    #
    #   object = "foo"
    #   matcher = change(object, :to_s).from("foo").to("FOO")
    #   matcher.match? { object.upcase! } # => true
    #
    #   object = "foo"
    #   matcher = change(object, :to_s).to("FOO")
    #   matcher.match? { object.upcase! } # => true
    #
    # @param object [#object_id]  An object.
    # @param method [Symbol]      The name of a method.
    #
    # @return [#match?] A change matcher.
    #
    # @api public
    def change(object, method, ...)
      ::Matchi::Change.new(object, method, ...)
    end

    # Satisfy matcher
    #
    # @example
    #   matcher = satisfy { |value| value == 42 }
    #   matcher.match? { 42 } # => true
    #
    # @yield [value] A block that defines the satisfaction criteria
    # @yieldparam value The value to test
    # @yieldreturn [Boolean] true if the value satisfies the criteria
    #
    # @return [#match?] A satisfy matcher.
    #
    # @api public
    def satisfy(&)
      ::Matchi::Satisfy.new(&)
    end

    private

    # Predicate matcher, or default method missing behavior.
    #
    # @example Empty predicate matcher
    #   matcher = be_empty
    #   matcher.match? { [] } # => true
    #   matcher.match? { [4] } # => false
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
