# frozen_string_literal: true

require_relative File.join("fix", "doc")
require_relative File.join("fix", "dsl")
require_relative File.join("fix", "test")

# The Kernel module.
module Kernel
  # Specifications are built with this method.
  #
  # @example Require an answer equal to 42.
  #   # The spec
  #   Fix :Answer do
  #     it MUST equal 42
  #   end
  #
  #   # The test
  #   Fix[:Answer].test { 42 }
  #
  # @param name   [String, Symbol]  The name of the specification document.
  # @param block  [Proc]            The specifications.
  #
  # @return [Class] The specification document.
  #
  # rubocop:disable Naming/MethodName
  def Fix(name = nil, &block)
    klass = ::Class.new(::Fix::Dsl)
    klass.const_set(:CONTEXTS, [klass])
    klass.instance_eval(&block)

    ::Fix::Doc.const_set(name, klass) unless name.nil?

    ::Fix::Test.new(*klass.const_get(:CONTEXTS))
  end
  # rubocop:enable Naming/MethodName
end
