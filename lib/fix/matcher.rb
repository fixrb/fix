# frozen_string_literal: true

require "matchi/be_a_kind_of"
require "matchi/be_an_instance_of"
require "matchi/be_within"
require "matchi/be"
require "matchi/change"
require "matchi/eq"
require "matchi/match"
require "matchi/raise_exception"
require "matchi/satisfy"
require_relative "matcher/fix"

module Fix
  # Comprehensive collection of expectation matchers for testing object behavior and state.
  #
  # The Matcher module provides matchers in several categories:
  # - Comparison: eq, eql, be, equal
  # - Type: be_an_instance_of, be_a_kind_of
  # - State Changes: change
  # - Numeric: be_within
  # - Pattern: match, satisfy
  # - Exception: raise_exception
  # - State: be_true, be_false, be_nil
  # - Specification: fix
  #
  # All matchers integrate with Fix's expectation system using RFC 2119 requirement levels:
  # - MUST/MUST_NOT for absolute requirements
  # - SHOULD/SHOULD_NOT for recommendations
  # - MAY for optional features
  #
  # @example Basic value comparison
  #   it MUST eq(42)
  #   it MUST be(same_object)
  #
  # @example Specification reuse
  #   Fix :Validatable do
  #     it MUST respond_to(:valid?)
  #     it MUST satisfy { |obj| obj.valid? }
  #   end
  #
  #   Fix :User do
  #     it MUST fix(:Validatable)
  #   end
  #
  # @see Fix::Requirement for requirement levels
  # @see https://tools.ietf.org/html/rfc2119 RFC 2119 Requirement Levels
  module Matcher
    # Creates an equality matcher using Object#eql?.
    #
    # This matcher verifies that objects have the same value, not necessarily
    # being the same object instance. It uses Ruby's eql? method which provides
    # type-safe equality comparison.
    #
    # @example Basic equality
    #   matcher = eq(42)
    #   matcher.match? { 42 }        # => true
    #   matcher.match? { 42.0 }      # => false
    #
    # @example With collections
    #   matcher = eq([1, 2, 3])
    #   matcher.match? { [1, 2, 3] }         # => true
    #   matcher.match? { [1, 2, 3].dup }     # => true
    #
    # @param expected [Object] Value to compare against
    #
    # @return [#match?] An equality matcher
    #
    # @api public
    def eq(expected)
      ::Matchi::Eq.new(expected)
    end

    alias eql eq

    # Creates an identity matcher using Object#equal?.
    #
    # This matcher verifies that objects are the exact same instance in memory,
    # not just equal values. It's particularly useful when testing object
    # references and caching behavior.
    #
    # @example Basic identity
    #   str = "test"
    #   matcher = be(str)
    #   matcher.match? { str }        # => true
    #   matcher.match? { str.dup }    # => false
    #
    # @example With symbols
    #   matcher = be(:status)
    #   matcher.match? { :status }    # => true
    #   matcher.match? { :other }     # => false
    #
    # @param expected [Object] Object to compare identity with
    #
    # @return [#match?] An identity matcher
    #
    # @api public
    def be(expected)
      ::Matchi::Be.new(expected)
    end

    alias equal be

    # Creates a numeric delta comparison matcher.
    #
    # This matcher checks if a numeric value falls within a specified range
    # of the target value. It's particularly useful for floating point
    # comparisons or when exact matches aren't required.
    #
    # @example Basic delta comparison
    #   matcher = be_within(0.1).of(3.14)
    #   matcher.match? { 3.141 }      # => true
    #   matcher.match? { 3.5 }        # => false
    #
    # @example With integers
    #   matcher = be_within(2).of(100)
    #   matcher.match? { 101 }        # => true
    #   matcher.match? { 103 }        # => false
    #
    # @param delta [Numeric] Allowed difference from target value
    #
    # @return [#of] A delta comparison builder
    #
    # @api public
    def be_within(delta)
      ::Matchi::BeWithin.new(delta)
    end

    # Creates a pattern matching matcher using Regexp#match?.
    #
    # This matcher verifies that a value matches a given regular expression
    # pattern. It's useful for string format validation and pattern matching.
    #
    # @example Basic pattern matching
    #   matcher = match(/^\d{3}-\d{2}$/)
    #   matcher.match? { "123-45" }   # => true
    #   matcher.match? { "abc" }      # => false
    #
    # @example Case insensitive matching
    #   matcher = match(/^test$/i)
    #   matcher.match? { "TEST" }     # => true
    #   matcher.match? { "other" }    # => false
    #
    # @param expected [Regexp] Pattern to match against
    #
    # @return [#match?] A pattern matcher
    #
    # @api public
    def match(expected)
      ::Matchi::Match.new(expected)
    end

    # Creates an exception matcher.
    #
    # This matcher verifies that code raises a specific exception type.
    # It supports both exact exception class matching and inheritance.
    #
    # @example Basic exception matching
    #   matcher = raise_exception(ArgumentError)
    #   matcher.match? { raise ArgumentError }  # => true
    #   matcher.match? { raise RuntimeError }   # => false
    #
    # @example With inheritance
    #   class CustomError < StandardError; end
    #   matcher = raise_exception(StandardError)
    #   matcher.match? { raise CustomError }    # => true
    #
    # @param expected [Class, String] Exception class or name
    #
    # @return [#match?] An exception matcher
    #
    # @api public
    def raise_exception(expected)
      ::Matchi::RaiseException.new(expected)
    end

    # Creates a true value matcher.
    #
    # @example
    #   matcher = be_true
    #   matcher.match? { true }     # => true
    #   matcher.match? { 1 }        # => false
    #
    # @return [#match?] A true matcher
    #
    # @api public
    def be_true
      be(true)
    end

    # Creates a false value matcher.
    #
    # @example
    #   matcher = be_false
    #   matcher.match? { false }    # => true
    #   matcher.match? { nil }      # => false
    #
    # @return [#match?] A false matcher
    #
    # @api public
    def be_false
      be(false)
    end

    # Creates a nil value matcher.
    #
    # @example
    #   matcher = be_nil
    #   matcher.match? { nil }      # => true
    #   matcher.match? { false }    # => false
    #
    # @return [#match?] A nil matcher
    #
    # @api public
    def be_nil
      be(nil)
    end

    # Creates an exact class type matcher.
    #
    # This matcher verifies that an object is an instance of exactly the
    # specified class, not counting inheritance or module inclusion.
    #
    # @example Basic class matching
    #   matcher = be_an_instance_of(String)
    #   matcher.match? { "test" }     # => true
    #   matcher.match? { :test }      # => false
    #
    # @example With inheritance
    #   class Parent; end
    #   class Child < Parent; end
    #
    #   matcher = be_an_instance_of(Parent)
    #   matcher.match? { Child.new }  # => false
    #
    # @param expected [Class, String] Class or class name
    #
    # @return [#match?] A class type matcher
    #
    # @api public
    def be_an_instance_of(expected)
      ::Matchi::BeAnInstanceOf.new(expected)
    end

    # Creates a class hierarchy matcher.
    #
    # This matcher verifies that an object's class inherits from or includes
    # the specified class or module, supporting the full inheritance chain.
    #
    # @example Basic kind matching
    #   matcher = be_a_kind_of(Numeric)
    #   matcher.match? { 42 }        # => true
    #   matcher.match? { 42.0 }      # => true
    #
    # @example With modules
    #   module Walkable; end
    #   class Dog
    #     include Walkable
    #   end
    #
    #   matcher = be_a_kind_of(Walkable)
    #   matcher.match? { Dog.new }   # => true
    #
    # @param expected [Class, Module, String] Class/module or name
    #
    # @return [#match?] A kind matcher
    #
    # @api public
    def be_a_kind_of(expected)
      ::Matchi::BeAKindOf.new(expected)
    end

    # Creates a state change matcher.
    #
    # This matcher verifies changes in object state by monitoring method
    # return values before and after an operation. It supports various
    # types of change verification including exact deltas, minimums,
    # maximums, and value transitions.
    #
    # @example Basic state change
    #   counter = 0
    #   matcher = change(counter, :to_i).by(5)
    #   matcher.match? { counter += 5 }   # => true
    #
    # @example Minimum change
    #   array = []
    #   matcher = change(array, :size).by_at_least(2)
    #   matcher.match? { array.push(1, 2, 3) }  # => true
    #
    # @example State transition
    #   user.status = "pending"
    #   matcher = change(user, :status).from("pending").to("active")
    #   matcher.match? { user.activate! }  # => true
    #
    # @example With method arguments
    #   hash = { key: 'value' }
    #   matcher = change(hash, :fetch, :key).to('new_value')
    #   matcher.match? { hash[:key] = 'new_value' }  # => true
    #
    # @param object [Object] Object to monitor
    # @param method [Symbol] Method to track
    # @param args [Array] Additional positional arguments to pass to the method
    # @param kwargs [Hash] Additional keyword arguments to pass to the method
    # @param block [Proc] Optional block to pass to the method
    #
    # @return [#by, #by_at_least, #by_at_most, #from, #to, #match?] A change matcher
    #
    # @api public
    def change(object, method, *args, **kwargs, &block)
      ::Matchi::Change.new(object, method, *args, **kwargs, &block)
    end

    # Creates a custom predicate matcher.
    #
    # This matcher allows defining arbitrary validation logic through a block.
    # It's useful when built-in matchers don't provide the needed verification.
    #
    # @example Basic predicate
    #   matcher = satisfy { |x| x.positive? && x.even? }
    #   matcher.match? { 42 }       # => true
    #   matcher.match? { 43 }       # => false
    #
    # @example Complex validation
    #   matcher = satisfy { |user|
    #     user.name.length >= 2 && user.age >= 18
    #   }
    #   matcher.match? { User.new("Alice", 25) }  # => true
    #
    # @yield [value] Block defining validation logic
    # @yieldparam value Object to validate
    # @yieldreturn [Boolean] true if validation passes
    #
    # @return [#match?] A custom predicate matcher
    #
    # @api public
    def satisfy(&)
      ::Matchi::Satisfy.new(&)
    end

    # Creates a Fix specification matcher for testing against Fix specs.
    # This matcher enables specification reuse and composition by allowing:
    # - Testing against named specifications
    # - Testing against inline anonymous specifications
    # - Combining multiple specifications
    # - Building shared specification libraries
    #
    # @example With named specification
    #   Fix :Validatable do
    #     it MUST respond_to(:valid?)
    #   end
    #
    #   Fix :User do
    #     it MUST fix(:Validatable)   # User must satisfy Validatable spec
    #     it MUST have_key(:email)    # Plus additional requirements
    #   end
    #
    # @example With anonymous specification
    #   Fix :Number do
    #     it MUST fix {
    #       it MUST be_positive
    #       it MUST be_even
    #     }
    #   end
    #
    # @example Failed match
    #   Fix :InvalidUser do
    #     it MUST fix(:Validatable)  # Fails if subject doesn't implement valid?
    #   end
    #
    # @param name [Symbol, nil] Name of registered specification
    # @yield Block containing anonymous specification
    # @return [#match?] A specification matcher
    # @see Fix::Spec The Fix testing framework
    #
    # @api public
    def fix(name)
      ::Fix::Matcher::Fix.new(name)
    end
  end
end
