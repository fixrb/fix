# frozen_string_literal: true

require_relative "fix/doc"
require_relative "fix/error/specification_not_found"
require_relative "fix/set"
require_relative "kernel"

# Namespace for the Fix framework.
#
# Provides core functionality for managing and running test specifications.
# Fix supports two modes of operation:
# 1. Named specifications that can be referenced later
# 2. Anonymous specifications for immediate testing
#
# @example Creating and running a named specification
#   Fix :Answer do
#     it MUST equal 42
#   end
#
#   Fix[:Answer].test { 42 }
#
# @example Creating and running an anonymous specification
#   Fix do
#     it MUST be_positive
#   end.test { 42 }
#
# @see Fix::Set
# @see Fix::Builder
#
# @api public
module Fix
  class << self
    # Retrieves and loads a built specification for testing.
    #
    # @example Run a named specification
    #   Fix[:Answer].test { 42 }
    #
    # @param name [String, Symbol] The constant name of the specification
    # @return [Fix::Set] The loaded specification set ready for testing
    # @raise [Fix::Error::SpecificationNotFound] If the named specification doesn't exist
    def [](name)
      name = normalize_name(name)
      validate_specification_exists!(name)
      Set.load(name)
    end

    # Lists all defined specification names.
    #
    # @example Get all specification names
    #   Fix.specification_names #=> [:Answer, :Calculator, :UserProfile]
    #
    # @return [Array<Symbol>] Sorted array of specification names
    def specification_names
      Doc.constants.sort
    end

    # Checks if a specification is defined.
    #
    # @example Check for specification existence
    #   Fix.spec_defined?(:Answer) #=> true
    #
    # @param name [String, Symbol] Name of the specification to check
    # @return [Boolean] true if specification exists, false otherwise
    def spec_defined?(name)
      specification_names.include?(normalize_name(name))
    end

    private

    # Converts any specification name into a symbol.
    # This allows for consistent name handling regardless of input type.
    #
    # @param name [String, Symbol] The name to normalize
    # @return [Symbol] The normalized name
    # @example
    #   normalize_name("Answer") #=> :Answer
    #   normalize_name(:Answer)  #=> :Answer
    def normalize_name(name)
      String(name).to_sym
    end

    # Verifies the existence of a specification and raises an error if not found.
    # This ensures early failure when attempting to use undefined specifications.
    #
    # @param name [Symbol] The specification name to validate
    # @raise [Fix::Error::SpecificationNotFound] If specification doesn't exist
    def validate_specification_exists!(name)
      return if spec_defined?(name)

      raise Error::SpecificationNotFound, name
    end
  end
end
