# frozen_string_literal: true

require "defi/method"

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
    # @return [Symbol] A private method that define the block content.
    #
    # @api public
    def self.let(name, &)
      private define_method(name, &)
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
    # @param kwargs [Hash] The list of propreties.
    # @yield The block that defines the specs for this context
    # @yieldreturn [void]
    #
    # @api public
    def self.with(**kwargs, &)
      klass = ::Class.new(self)
      klass.const_get(:CONTEXTS) << klass
      kwargs.each { |name, value| klass.let(name) { value } }
      klass.instance_eval(&)
      klass
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
    # @param method_name [String, Symbol] The method to send to the subject.
    # @param block [Proc] The block to define the specs.
    #
    # @api public
    def self.on(method_name, *args, **kwargs, &block)
      klass = ::Class.new(self)
      klass.const_get(:CONTEXTS) << klass

      const_set(:"Child#{block.object_id}", klass)

      klass.define_singleton_method(:challenges) do
        challenge = ::Defi::Method.new(method_name, *args, **kwargs)
        super() + [challenge]
      end

      klass.instance_eval(&block)
      klass
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
    # @api public
    def self.it(requirement = nil, &block)
      raise ::ArgumentError, "Must provide either requirement or block, not both" if requirement && block
      raise ::ArgumentError, "Must provide either requirement or block" unless requirement || block

      location = caller_locations(1, 1).fetch(0)
      location = [location.path, location.lineno].join(":")

      define_method(:"test_#{(requirement || block).object_id}") do
        [location, requirement || singleton_class.class_eval(&block), self.class.challenges]
      end
    end

    # The list of challenges to be addressed to the object to be tested.
    #
    # @return [Array<Defi::Method>] A list of challenges.
    def self.challenges
      []
    end
  end
end
