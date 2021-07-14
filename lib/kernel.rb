# frozen_string_literal: true

require_relative File.join("fix", "doc")
require_relative File.join("fix", "dsl")
require_relative File.join("fix", "test")

# The Kernel module.
module Kernel
  # Specifications are built with this method.
  #
  # @example Fix 42 such as it must be equal to 42.
  #   Fix :Answer do
  #     it { MUST equal 42 }
  #   end
  #
  # @param name   [String, Symbol]  The name of the specification document.
  # @param block  [Proc]            The specifications.
  #
  # @return [Class] The specification document.
  #
  # rubocop:disable Naming/MethodName
  def Fix(name, &block)
    klass = ::Class.new(::Fix::Dsl)
    klass.const_set(:SPECS, [klass])
    klass.instance_eval(&block)
    ::Fix::Doc.const_set(name, klass)
    ::Fix::Test.new(name)
  end
  # rubocop:enable Naming/MethodName
end
