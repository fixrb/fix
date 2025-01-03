# frozen_string_literal: true

require_relative "fix/doc"
require_relative "fix/error/missing_specification_block"
require_relative "fix/error/specification_not_found"
require_relative "fix/set"
require_relative "kernel"

# The Fix framework namespace provides core functionality for managing and running test specifications.
# Fix offers a unique approach to testing by clearly separating specifications from their implementations.
#
# Fix supports two primary modes of operation:
# 1. Named specifications that can be stored and referenced later
# 2. Anonymous specifications for immediate one-time testing
#
# Available matchers through the Matchi library include:
# - Basic Comparison: eq, eql, be, equal
# - Type Checking: be_an_instance_of, be_a_kind_of
# - State & Changes: change(object, method).by(n), by_at_least(n), by_at_most(n), from(old).to(new), to(new)
# - Value Testing: be_within(delta).of(value), match(regex), satisfy { |value| ... }
# - Exceptions: raise_exception(class)
# - State Testing: be_true, be_false, be_nil
# - Predicate Matchers: be_*, have_*  (e.g., be_empty, have_key)
#
# @example Creating and running a named specification with various matchers
#   Fix :Calculator do
#     on(:add, 0.1, 0.2) do
#       it SHOULD be 0.3                     # Technically true but fails due to floating point precision
#       it MUST be_an_instance_of(Float)     # Type checking
#       it MUST be_within(0.0001).of(0.3)    # Proper floating point comparison
#     end
#
#     on(:divide, 1, 0) do
#       it MUST raise_exception ZeroDivisionError  # Exception testing
#     end
#   end
#
#   Fix[:Calculator].test { Calculator.new }
#
# @example Using state change matchers
#   Fix :UserAccount do
#     on(:deposit, 100) do
#       it MUST change(account, :balance).by(100)
#       it SHOULD change(account, :updated_at)
#     end
#
#     on(:update_status, :premium) do
#       it MUST change(account, :status).from(:basic).to(:premium)
#     end
#   end
#
# @example Using predicate matchers
#   Fix :Collection do
#     with items: [] do
#       it MUST be_empty          # Tests empty?
#       it MUST_NOT have_errors   # Tests has_errors?
#     end
#   end
#
# @example Complete specification with multiple matchers
#   Fix :Product do
#     let(:price) { 42.99 }
#
#     it MUST be_an_instance_of Product     # Type checking
#     it MUST_NOT be_nil                    # Nil checking
#
#     on(:price) do
#       it MUST be_within(0.01).of(42.99)   # Floating point comparison
#     end
#
#     with category: "electronics" do
#       it MUST satisfy { |p| p.valid? }    # Custom validation
#
#       on(:save) do
#         it MUST change(product, :updated_at)  # State change
#         it SHOULD_NOT raise_exception         # Exception checking
#       end
#     end
#   end
#
# @see Fix::Set For managing collections of specifications
# @see Fix::Doc For storing and retrieving specifications
# @see Fix::Dsl For the domain-specific language used in specifications
# @see Fix::Matcher For the complete list of available matchers
#
# @api public
module Fix
  # Creates a new specification set, optionally registering it under a name.
  #
  # @param name [Symbol, nil] Optional name to register the specification under.
  #   If nil, creates an anonymous specification for immediate use.
  # @yieldreturn [void] Block containing the specification definition using Fix DSL
  # @return [Fix::Set] A new specification set ready for testing
  # @raise [Fix::Error::MissingSpecificationBlock] If no block is provided
  #
  # @example Create a named specification
  #   Fix :StringValidator do
  #     on(:validate, "hello@example.com") do
  #       it MUST be_valid_email
  #       it MUST satisfy { |result| result.errors.empty? }
  #     end
  #   end
  #
  # @example Create an anonymous specification
  #   Fix do
  #     it MUST be_positive
  #     it MUST be_within(0.1).of(42.0)
  #   end.test { 42 }
  #
  # @api public
  def self.spec(name = nil, &block)
    raise Error::MissingSpecificationBlock if block.nil?

    Set.build(name, &block)
  end

  # Retrieves a previously registered specification by name.
  #
  # @param name [Symbol] The constant name of the specification to retrieve
  # @return [Fix::Set] The loaded specification set ready for testing
  # @raise [Fix::Error::SpecificationNotFound] If the named specification doesn't exist
  #
  # @example
  #   # Define a specification with multiple matchers
  #   Fix :EmailValidator do
  #     on(:validate, "test@example.com") do
  #       it MUST be_valid
  #       it MUST_NOT raise_exception
  #       it SHOULD satisfy { |result| result.score > 0.8 }
  #     end
  #   end
  #
  #   # Later, retrieve and use it
  #   Fix[:EmailValidator].test { MyEmailValidator }
  #
  # @see #spec For creating new specifications
  # @see Fix::Set#test For running tests against a specification
  # @see Fix::Matcher For available matchers
  #
  # @api public
  def self.[](name)
    raise Error::SpecificationNotFound, name unless key?(name)

    Set.load(name)
  end

  # Lists all defined specification names.
  #
  # @return [Array<Symbol>] Sorted array of registered specification names
  #
  # @example
  #   Fix :First do; end
  #   Fix :Second do; end
  #
  #   Fix.keys #=> [:First, :Second]
  #
  # @api public
  def self.keys
    Doc.constants.sort
  end

  # Checks if a specification is registered under the given name.
  #
  # @param name [Symbol] The name to check for
  # @return [Boolean] true if a specification exists with this name, false otherwise
  #
  # @example
  #   Fix :Example do
  #     it MUST be_an_instance_of(Example)
  #   end
  #
  #   Fix.key?(:Example)  #=> true
  #   Fix.key?(:Missing)  #=> false
  #
  # @api public
  def self.key?(name)
    keys.include?(name)
  end
end
