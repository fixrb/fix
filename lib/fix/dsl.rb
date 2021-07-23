# frozen_string_literal: true

require "defi"
require "spectus"

require_relative "matcher"
require_relative "test"

module Fix
  # Abstract class for handling the domain-specific language.
  class Dsl
    extend Matcher

    # Sets a user-defined property.
    #
    # @example
    #   require "fix"
    #
    #   Fix do
    #     let(:name) { "Bob" }
    #   end
    #
    # @param name   [String, Symbol] The name of the property.
    # @param block  [Proc] The content of the method to define.
    #
    # @return [Symbol] A private method that define the block content.
    #
    # @api public
    def self.let(name, &block)
      private define_method(name, &block)
    end

    # Defines an example group with user-defined properties that describes a
    # unit to be tested.
    #
    # @example
    #   require "fix"
    #
    #   Fix do
    #     with :password, "secret" do
    #       it MUST equal true
    #     end
    #   end
    #
    # @param kwargs [Hash] The list of propreties.
    # @param block [Proc] The block to define the specs.
    #
    # @api public
    def self.with(**kwargs, &block)
      klass = ::Class.new(self)
      klass.const_get(:CONTEXTS) << klass
      kwargs.each { |name, value| klass.let(name) { value } }
      klass.instance_eval(&block)
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

      const_set("Child#{block.object_id}", klass)

      klass.define_singleton_method(:challenges) do
        super() + [::Defi.send(method_name, *args, **kwargs)]
      end

      def klass.initialize
        if subject.raised?
          subject
        else
          challenge = ::Defi.send(method_name, *args, **kwargs)
          challenge.to(subject.call)
        end
      end

      klass.instance_eval(&block)
      klass
    end

    # Defines a concrete spec definition.
    #
    # @example
    #   require "fix"
    #
    #   Fix { it MUST equal 42 }
    #
    # @api public
    def self.it(requirement)
      define_method("test_#{requirement.object_id}") { requirement }
    end

    # @todo Move this method inside "fix-its" gem.
    def self.its(method_name, requirement)
      klass = ::Class.new(self)
      klass.const_get(:CONTEXTS) << klass

      const_set("Child#{requirement.object_id}", klass)

      klass.define_singleton_method(:challenges) do
        super() + [::Defi.send(method_name)]
      end

      def klass.initialize
        if subject.raised?
          subject
        else
          challenge = ::Defi.send(method_name, *args, **kwargs)
          challenge.to(subject.call)
        end
      end

      klass.it(requirement)
    end

    def self.challenges
      []
    end

    def self.test(&subject)
      Test.new(self).test(&subject)
    end

    private_class_method :challenges

    private

    attr_reader :subject

    def initialize(&subject)
      @subject = ::Defi::Value.new(&subject)
    end

    ::Spectus.methods(false).each do |method_name|
      define_singleton_method(method_name.upcase) do |matcher|
        ::Spectus.public_send(method_name, matcher)
      end
    end
  end
end
