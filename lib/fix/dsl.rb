# frozen_string_literal: true

require "defi/method"
require "pathname"
require "securerandom"

require_relative "matcher"
require_relative "requirement"

module Fix
  # Abstract class for handling the domain-specific language.
  #
  # @api private
  class Dsl
    extend Matcher
    extend Requirement

    # Sets a user-defined property.
    #
    # @example
    #   require "fix"
    #
    #   Fix do
    #     let(:name) { "Bob" }
    #   end
    #
    # @param name [String, Symbol] The name of the property.
    # @yield The block that defines the property's value
    # @yieldreturn [Object] The value to be returned by the property
    #
    # @return [Symbol] A private method that defines the block content.
    #
    # @api public
    def self.let(name, &block)
      raise ::ArgumentError, "name must be a Symbol" unless name.is_a?(Symbol)
      raise ::ArgumentError, "block must be provided" unless block_given?

      private define_method(name, &block)

      nil
    end

    # Defines an example group with user-defined properties that describes a
    # unit to be tested.
    #
    # @example
    #   require "fix"
    #
    #   Fix do
    #     with password: "secret" do
    #       it MUST be true
    #     end
    #   end
    #
    # @param kwargs [Hash] The list of properties to define in this context
    # @yield The block that defines the specs for this context
    # @yieldreturn [void]
    #
    # @return [Class] A new class representing this context
    #
    # @api public
    def self.with(**kwargs, &block)
      new_class = ::Class.new(self)
      new_class_name = "C#{::SecureRandom.alphanumeric}"
      const_set(new_class_name, new_class)
      kwargs.each { |name, value| new_class.let(name) { value } }
      new_class.class_eval(&block)

      nil
    end

    # Defines an example group that describes a unit to be tested.
    #
    # @example
    #   require "fix"
    #
    #   Fix do
    #     on :+, 2 do
    #       it MUST be 42
    #     end
    #   end
    #
    # @param method_name [String, Symbol] The method to send to the subject
    # @param args [Array] Positional arguments to pass to the method
    # @param kwargs [Hash] Keyword arguments to pass to the method
    # @yield The block containing the specifications for this context
    # @yieldreturn [void]
    #
    # @return [Class] A new class representing this context
    #
    # @api public
    def self.on(method_name, *args, **kwargs, &block)
      new_class = ::Class.new(self)
      name = "C#{::SecureRandom.alphanumeric}"
      const_set(name, new_class)

      new_class.define_singleton_method(:challenges) do
        challenge = ::Defi::Method.new(method_name, *args, **kwargs)
        super() + [challenge]
      end

      new_class.class_eval(&block)

      nil
    end

    # Defines a concrete spec definition.
    #
    # @example
    #   require "fix"
    #
    #   Fix { it MUST be 42 }
    #
    #   Fix do
    #     it { MUST be 42 }
    #   end
    #
    def self.it(definition)
      location = caller_locations(1, 1).fetch(0)
      location = [relative_path_from_pwd(location.path), location.lineno].join(":")
      test_method_name = :"m_#{::SecureRandom.hex(4)}"

      define_method(test_method_name) do
        [
          definition,
          location
        ]
      end

      nil
    end

    # Convert an absolute path to a path relative to the current working directory
    #
    # @param absolute_path [String] The absolute path to convert
    # @return [String] The relative path from the current working directory
    def self.relative_path_from_pwd(absolute_path)
      ::Pathname.new(absolute_path).relative_path_from(::Pathname.pwd)
    rescue ArgumentError => _e
      ::Pathname.pwd
    end
  end
end
