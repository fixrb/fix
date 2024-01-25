# frozen_string_literal: true

require_relative File.join("fix", "doc")
require_relative File.join("fix", "dsl")
require_relative File.join("fix", "set")

# The Kernel module.
module Kernel
  # rubocop:disable Naming/MethodName

  # Specifications are built with this method.
  #
  # @example Require an answer equal to 42.
  #   # The spec
  #   Fix :Answer do
  #     it MUST equal 42
  #   end
  #
  #   # A test
  #   Fix[:Answer].test { 42 }
  #
  # @param name   [String, Symbol]  The constant name of the specifications.
  # @param block  [Proc]            The specifications.
  #
  # @return [#test] The collection of specifications.
  #
  # @api public
  def Fix(name = nil, &)
    klass = ::Class.new(::Fix::Dsl)
    klass.const_set(:CONTEXTS, [klass])
    klass.instance_eval(&)
    ::Fix::Doc.const_set(name, klass) unless name.nil?
    ::Fix::Set.new(*klass.const_get(:CONTEXTS))
  end

  # rubocop:enable Naming/MethodName
end
