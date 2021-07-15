# frozen_string_literal: true

require "defi"
require "matchi/helper"
require "spectus"

require_relative "console"

module Fix
  # Abstract class for handling the domain-specific language.
  class Dsl
    include ::Matchi::Helper

    # Sets a user-defined property.
    #
    # @example
    #   require "fix"
    #
    #   Fix.describe "Name stories" do
    #     let(:name) { "Bob" }
    #
    #     it { expect(name).to eq "Bob" }
    #
    #     context "with last name" do
    #       let(:name) { "#{super()} Smith" }
    #
    #       it { expect(name).to eq "Bob Smith" }
    #     end
    #   end
    #
    #   # Output to the console
    #   #   Success: expected to eq "Bob".
    #   #   Success: expected to eq "Bob Smith".
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

    def self.with(**kwargs, &block)
      klass = ::Class.new(self)
      kwargs.each { |name, value| klass.let(name) { value } }
      klass.instance_eval(&block)
      klass
    end

    # Defines an example group that describes a unit to be tested.
    #
    # @example
    #   require "fix"
    #
    #   Fix.on String do
    #     on "+" do
    #       it("concats") { expect("foo" + "bar").to eq "foobar" }
    #     end
    #   end
    #
    #   # Output to the console
    #   #   Success: expected to eq "foobar".
    #
    # @param const [Module, String] A module to include in block context.
    # @param block [Proc] The block to define the specs.
    #
    # @api public
    def self.on(method_name, *args, **kwargs, &block)
      klass = ::Class.new(self)
      klass.const_get(:SPECS) << klass
      const_set("Child#{block.object_id}", klass)

      klass.define_singleton_method(:challenges) do
        super() + [::Defi.send(method_name, *args, **kwargs)]
      end

      klass.instance_eval(&block)
      klass
    end

    # Defines a concrete test case.
    #
    # The test is performed by the block supplied to `&block`.
    #
    # @example The integer after 41
    #   require "fix"
    #
    #   Fix(:AnswerToEverything) { it { MUST be 42 } }.call(42)
    #
    #   # Output to the console
    #   #   Success: expected to be 42.
    #
    # @example A division by zero
    #   require "fix"
    #
    #   Fix :Integer do
    #     it { MUST be_an_instance_of Integer }
    #
    #     on :/, 0 do
    #       it { MUST raise_exception ZeroDivisionError }
    #     end
    #   end
    #
    #   Fix[:Integer].call(41)
    #
    #   # Output to the console
    #   #   Success: expected 41 to be an instance of Integer.
    #   #   Success: divided by 0.
    #
    # It can be used inside a {.describe} or {.context} section.
    #
    # @param block [Proc] An expectation to evaluate.
    #
    # @raise (see ExpectationTarget::Base#result)
    # @return (see ExpectationTarget::Base#result)
    #
    # @api public
    def self.it(&block)
      define_method("test_#{block.object_id}", &block)
    end

    def self.its(method_name, *args, **kwargs, &block)
      klass = ::Class.new(self)
      klass.const_get(:SPECS) << klass
      const_set("Child#{block.object_id}", klass)

      klass.define_singleton_method(:challenges) do
        super() + [::Defi.send(method_name, *args, **kwargs)]
      end

      klass.it(&block)
    end

    def self.challenges
      []
    end

    private_class_method :challenges

    private

    def initialize(subject)
      @subject = subject
    end

    ::Spectus.methods(false).each do |method_name|
      define_method(method_name.upcase) do |matcher|
        ::Spectus.public_send(method_name, matcher).call do
          self.class.send(:challenges).inject(@subject) do |object, challenge|
            challenge.to(object).call
          end
        end
      end
    end
  end
end
