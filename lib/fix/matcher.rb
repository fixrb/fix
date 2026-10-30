# frozen_string_literal: true

require "matchi"

module Fix
  # The matchers of a specification, as words: each one builds a matcher of
  # Matchi, or returns a specification, which is a matcher too, and raises
  # `ArgumentError` at load for an argument the matcher refuses. Any object
  # with `match?` and `to_s` is accepted by the levels as well.
  module Matcher
    # @param expected [Object] the expected value
    # @return [Matchi::Eq] `eql?` to the expected value, of its class
    def eq(expected)
      ::Matchi::Eq.new(expected)
    end

    # @param expected [Object] the expected object
    # @return [Matchi::Be] the very same object
    def be(expected)
      ::Matchi::Be.new(expected)
    end

    # @param delta [Numeric] the tolerance
    # @return [Matchi::BeWithin] to complete with `of(expected)`
    def be_within(delta)
      ::Matchi::BeWithin.new(delta)
    end

    # @param expected [Regexp] the pattern
    # @return [Matchi::Match] a String or a Symbol matching the pattern
    def match(expected)
      ::Matchi::Match.new(expected)
    end

    # @param expected [Class, String, Symbol] the exception class, or its name
    # @param message [String, Regexp, nil] the expected message
    # @return [Matchi::RaiseException] raising that exception
    def raise_exception(expected, message = nil)
      ::Matchi::RaiseException.new(expected, message)
    end

    # @return [Matchi::Be] `true` itself
    def be_true
      ::Matchi::Be.new(true)
    end

    # @return [Matchi::Be] `false` itself
    def be_false
      ::Matchi::Be.new(false)
    end

    # @return [Matchi::Be] `nil` itself
    def be_nil
      ::Matchi::Be.new(nil)
    end

    # @param expected [Class, String, Symbol] the class, or its name
    # @return [Matchi::BeAnInstanceOf] an instance of that very class
    def be_an_instance_of(expected)
      ::Matchi::BeAnInstanceOf.new(expected)
    end

    # @param expected [Module, String, Symbol] the module, or its name
    # @return [Matchi::BeAKindOf] an instance of that module or of a descendant
    def be_a_kind_of(expected)
      ::Matchi::BeAKindOf.new(expected)
    end

    # The object must exist when the specification is loaded: a let, which
    # lives with the subject, cannot be observed.
    #
    # @param object [Object] the object to observe
    # @param method [Symbol, String] the method whose value may change,
    #   followed by its arguments and its block
    # @return [Matchi::Change] a change, or one to refine with `by`,
    #   `by_at_least`, `by_at_most`, `from … to` or `to`
    def change(object, method, ...)
      ::Matchi::Change.new(object, method, ...)
    end

    # @yieldparam value [Object] the actual value
    # @yieldreturn [Boolean] whether it satisfies the block
    # @return [Matchi::Satisfy]
    def satisfy(&)
      ::Matchi::Satisfy.new(&)
    end

    # @param name [Symbol, nil] the name of a registered specification
    # @yield the document of an anonymous specification, instead of a name
    # @return [Fix::Spec] the specification, tested against the actual value
    #   as a matcher
    # @raise [KeyError] when no specification has that name
    # @raise [ArgumentError] with both a name and a block, or neither
    def fix(name = nil, &block)
      raise ::ArgumentError, "a name or a block must be given, not both" if name.nil? == block.nil?

      name.nil? ? ::Fix.spec(&block) : ::Fix[name]
    end
  end
end
