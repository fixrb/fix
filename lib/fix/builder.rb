# frozen_string_literal: true

require_relative "doc"
require_relative "dsl"
require_relative "set"
require_relative "error/missing_specification_block"

module Fix
  # Handles the creation and setup of Fix specifications.
  #
  # The Builder constructs new Fix specification sets following these steps:
  # 1. Creates a new specification class inheriting from DSL
  # 2. Defines the specification content using the provided block
  # 3. Optionally registers the named specification
  # 4. Returns the built specification set
  #
  # @example Create a named specification
  #   Fix::Builder.build(:Calculator) do
  #     on(:add, 2, 3) { it MUST equal 5 }
  #   end
  #
  # @example Create an anonymous specification
  #   Fix::Builder.build do
  #     it MUST be_positive
  #   end
  #
  # @see Fix::Set
  # @see Fix::Dsl
  # @api private
  class Builder
    # Creates a new specification set.
    #
    # @param name [String, Symbol, nil] Optional name for the specification
    # @yieldparam [void] Block containing specification definitions
    # @yieldreturn [void]
    # @return [Fix::Set] The constructed specification set
    # @raise [Fix::Error::InvalidSpecificationName] If name is invalid
    # @raise [Fix::Error::MissingSpecificationBlock] If no block given
    def self.build(name = nil, &block)
      new(name, &block).construct_set
    end

    # @return [String, Symbol, nil] The name of the specification
    attr_reader :name

    def initialize(name = nil, &block)
      raise Error::MissingSpecificationBlock unless block

      @name = name
      @block = block
    end

    # Constructs and returns a new specification set.
    #
    # @return [Fix::Set] The constructed specification set
    def construct_set
      klass = create_specification
      populate_specification(klass)
      register_if_named(klass)
      build_set(klass)
    end

    private

    # @return [Proc] The block containing specification definitions
    attr_reader :block

    # Creates a new specification class with context tracking.
    #
    # @return [Class] A new class inheriting from Fix::Dsl with CONTEXTS initialized
    def create_specification
      ::Class.new(Dsl).tap do |klass|
        klass.const_set(:CONTEXTS, [klass])
      end
    end

    # Evaluates the specification block in the context of the class.
    #
    # @param klass [Class] The class to populate with specifications
    # @return [void]
    def populate_specification(klass)
      klass.instance_eval(&block)
    end

    # Registers the specification in Fix::Doc if a name was provided.
    #
    # @param klass [Class] The specification class to register
    # @return [void]
    def register_if_named(klass)
      Doc.spec_set(name, klass) if name
    end

    # Creates a new specification set from the populated class.
    #
    # @param klass [Class] The populated specification class
    # @return [Fix::Set] A new specification set
    def build_set(klass)
      Set.new(*klass.const_get(:CONTEXTS))
    end
  end
end
