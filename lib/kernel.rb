# frozen_string_literal: true

require_relative File.join('fix', 'dsl')

# The Kernel module.
module Kernel
  # Specifications are built with this method.
  #
  # @example Fix 42 such as it must be equal to 42.
  #   Fix(42) do
  #     it { MUST equal 42 }
  #   end
  #
  # @param block        [Proc]        The specifications.
  #
  # @raise [SystemExit] The result of the test.
  #
  # rubocop:disable Naming/MethodName
  def Fix(&block)
    ::Fix::Dsl.describe(&block)
  end
  # rubocop:enable Naming/MethodName
end
