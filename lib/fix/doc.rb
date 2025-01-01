# frozen_string_literal: true

require_relative "error/invalid_specification_name"

module Fix
  # Module for storing and managing specification documents.
  #
  # This module acts as a registry for specification classes and handles
  # the extraction of test specifications from context objects.
  #
  # @api private
  module Doc
    # Retrieves the contexts array for a named specification.
    #
    # @param name [String, Symbol] The constant name of the specification
    # @return [Array<Fix::Dsl>] Array of context classes for the specification
    # @raise [NameError] If specification constant is not found
    def self.fetch(name)
      const_get("#{name}::CONTEXTS")
    end

    # Extracts test specifications from a list of context classes.
    # Each specification consists of an environment and its associated test data.
    #
    # @param contexts [Array<Fix::Dsl>] List of context classes to process
    # @return [Array<Array>] Array of arrays where each sub-array contains:
    #   - [0] environment: The test environment instance
    #   - [1] location: The test file location (as "path:line")
    #   - [2] requirement: The test requirement (MUST, SHOULD, or MAY)
    #   - [3] challenges: Array of test challenges to execute
    def self.extract_specifications(*contexts)
      contexts.flat_map do |context|
        extract_context_specifications(context)
      end
    end

    # Registers a new specification class under the given name.
    #
    # @param name [String, Symbol] Name to register the specification under
    # @param klass [Class] The specification class to register
    # @raise [Fix::Error::InvalidSpecificationName] If name is not a valid constant name
    # @return [void]
    def self.spec_set(name, klass)
      const_set(name, klass)
    rescue ::NameError => _e
      raise Error::InvalidSpecificationName, name
    end

    # @private
    def self.extract_context_specifications(context)
      env = context.new
      env.public_methods(false).map do |public_method|
        [env] + env.public_send(public_method)
      end
    end

    private_class_method :extract_context_specifications
  end
end
