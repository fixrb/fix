# frozen_string_literal: true

require_relative "error/invalid_specification_name"

module Fix
  # The Doc module serves as a central registry for storing and managing test specifications.
  # It provides functionality for:
  # - Storing specification classes in a structured way
  # - Managing the lifecycle of specification documents
  # - Extracting test specifications from context objects
  # - Validating specification names
  #
  # The module acts as a namespace for specifications, allowing them to be:
  # - Registered with unique names
  # - Retrieved by name when needed
  # - Protected from name collisions
  # - Organized in a hierarchical structure
  #
  # @example Registering a new specification
  #   Fix::Doc.add(:Calculator, calculator_specification_class)
  #
  # @example Retrieving specification contexts
  #   contexts = Fix::Doc.fetch(:Calculator)
  #   specifications = Fix::Doc.extract_specifications(*contexts)
  #
  # @api private
  module Doc
    # Retrieves the array of test contexts associated with a named specification.
    # These contexts define the test environment and requirements for the specification.
    #
    # @param name [Symbol] The name of the specification to retrieve
    # @return [Array<Fix::Dsl>] Array of context classes for the specification
    # @raise [NameError] If the specification name doesn't exist in the registry
    #
    # @example Retrieving contexts for a calculator specification
    #   contexts = Fix::Doc.fetch(:Calculator)
    #   contexts.each do |context|
    #     # Process each context...
    #   end
    #
    # @api private
    def self.fetch(name)
      const_get("#{name}::CONTEXTS")
    end

    # Extracts complete test specifications from a list of context classes.
    # This method processes contexts to build a list of executable test specifications.
    #
    # Each extracted specification contains:
    # - The test environment
    # - The source file location
    # - The requirement level (MUST, SHOULD, or MAY)
    # - The list of challenges to execute
    #
    # @param contexts [Array<Fix::Dsl>] List of context classes to process
    # @return [Array<Array>] Array of specification arrays where each contains:
    #   - [0] environment [Fix::Dsl] The test environment instance
    #   - [1] location [String] The test file location ("path:line")
    #   - [2] requirement [Object] The test requirement (MUST, SHOULD, or MAY)
    #   - [3] challenges [Array] Array of test challenges to execute
    #
    # @example Extracting specifications from contexts
    #   contexts = Fix::Doc.fetch(:Calculator)
    #   specifications = Fix::Doc.extract_specifications(*contexts)
    #   specifications.each do |env, location, requirement, challenges|
    #     # Process each specification...
    #   end
    #
    # @api private
    def self.extract_specifications(*contexts)
      contexts.flat_map do |context|
        extract_context_specifications(context)
      end
    end

    # Registers a new specification class under the given name in the registry.
    # The name must be a valid Ruby constant name to ensure proper namespace organization.
    #
    # @param name [Symbol] The name to register the specification under
    # @param klass [Class] The specification class to register
    # @raise [Fix::Error::InvalidSpecificationName] If name is not a valid constant name
    # @return [void]
    #
    # @example Adding a new specification
    #   class CalculatorSpec < Fix::Dsl
    #     # specification implementation...
    #   end
    #   Fix::Doc.add(:Calculator, CalculatorSpec)
    #
    # @example Invalid name handling
    #   # This will raise Fix::Error::InvalidSpecificationName
    #   Fix::Doc.add(:"invalid-name", some_class)
    #
    # @api private
    def self.add(name, klass)
      const_set(name, klass)
    rescue ::NameError => _e
      raise Error::InvalidSpecificationName, name
    end

    # Extracts test specifications from a single context class.
    # This method processes public methods in the context to build
    # a list of executable test specifications.
    #
    # @param context [Fix::Dsl] The context class to process
    # @return [Array<Array>] Array of specification arrays
    #
    # @api private
    def self.extract_context_specifications(context)
      env = context.new
      env.public_methods(false).map do |public_method|
        [env] + env.public_send(public_method)
      end
    end

    private_class_method :extract_context_specifications
  end
end
