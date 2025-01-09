# frozen_string_literal: true

# require_relative "../spec"

module Fix
  module Matcher
    # Matcher for testing objects against Fix specifications.
    # This matcher allows for specification reuse and composition by enabling:
    # - Testing against named specifications stored in Fix registry
    # - Testing against inline anonymous specifications
    # - Sharing common behaviors across multiple specifications
    # - Building specification hierarchies through composition
    #
    # @example Using named specifications for shared behaviors
    #   # Define a reusable specification for validatable objects
    #   Fix :Validatable do
    #     it MUST respond_to(:valid?)
    #     it MUST respond_to(:errors)
    #
    #     on :valid? do
    #       it MUST be_boolean
    #     end
    #   end
    #
    #   # Reuse in concrete specifications
    #   Fix :User do
    #     it MUST fix(:Validatable)     # Must implement validation behavior
    #     it MUST have_key(:email)      # Plus User-specific requirements
    #   end
    #
    # @example Composing multiple specifications
    #   Fix :AdminUser do
    #     it MUST fix(:User)            # Must satisfy User specification
    #     it MUST fix(:HasPermissions)  # Plus permission behaviors
    #
    #     with role: :admin do
    #       it MUST be_admin            # Plus admin-specific behavior
    #     end
    #   end
    #
    # @example Using inline specifications
    #   Fix :Response do
    #     on :status do
    #       it MUST fix {               # Anonymous specification
    #         it MUST be_integer
    #         it MUST be_between(200, 599)
    #       }
    #     end
    #   end
    #
    # @api public
    # @see Fix::Spec For the specification system
    class Fix
      # Initializes a new Fix matcher instance.
      #
      # @api public
      #
      # @param name [Symbol, nil] Name of a registered Fix specification
      # @param block [Proc, nil] Block containing an anonymous specification
      #
      # @raise [ArgumentError] If neither or both name and block are provided
      # @raise [KeyError] If the named specification doesn't exist in registry
      #
      # @example With named specification
      #   # Test against registered specification
      #   matcher = Fix.new(:Validatable)
      #   matcher.match? { User.new }
      #
      # @example With anonymous specification
      #   # Test against inline requirements
      #   matcher = Fix.new {
      #     it MUST be_positive
      #     it MUST be_even
      #   }
      #   matcher.match? { 42 }
      #
      # @example Failed initialization
      #   # Raises ArgumentError
      #   Fix.new(:Name) { it MUST be_true } # Can't provide both
      #   Fix.new # Can't provide neither
      def initialize(name = nil, &block)
        raise ::ArgumentError, "a name or a block must be provided" if name.nil? && block.nil?
        raise ::ArgumentError, "a name or a block must be provided" if !name.nil? && !block.nil?

        @expected = if name.nil?
                      puts "just block"
                      ::Fix::Spec.build(nil, &block)
                    else
                      puts "just name #{name.inspect}"
                      # ::Fix::Spec.load(name)
                      Fix(name)
                    end
      end

      # Verifies if an object satisfies the Fix specification.
      #
      # Tests the provided object against all requirements defined in the
      # specification, including:
      # - Direct assertions (MUST, SHOULD, MAY)
      # - Method behavior tests (via 'on' blocks)
      # - Contextual requirements (via 'with' blocks)
      # - Nested specifications (via other 'fix' matchers)
      #
      # @api public
      #
      # @yield Block that returns the object to verify
      # @yieldreturn [Object] Object to test against the specification
      # @return [Boolean] true if object satisfies all requirements
      #
      # @example Basic matching
      #   Fix :Positive do
      #     it MUST be_positive
      #   end
      #
      #   matcher = Fix.new(:Positive)
      #   matcher.match? { 42 }      # => true
      #   matcher.match? { -1 }      # => false
      #
      # @example With composed specifications
      #   Fix :AdminUser do
      #     it MUST fix(:User)
      #     it MUST fix(:HasPermissions)
      #   end
      #
      #   matcher = Fix.new(:AdminUser)
      #   matcher.match? { admin }    # Tests all composed requirements
      #
      # @raise [ArgumentError] If no block is provided
      def match?
        raise ::ArgumentError, "a block must be provided" unless block_given?

        @expected.match?(yield)
      end

      # Provides a string representation of the matcher.
      #
      # @api public
      #
      # @return [String] Human-readable description of the matcher
      #
      # @example Named specification
      #   Fix.new(:Calculator).to_s  # => "fix Calculator"
      #
      # @example Anonymous specification
      #   Fix.new { it MUST be_true }.to_s  # => "fix #<Fix::Spec:...>"
      def to_s
        "fix #{@expected.inspect}"
      end
    end
  end
end
