# frozen_string_literal: true

# The `Fix` method, private: callable at the top level of a file, not on an
# object.
module Kernel
  private

  # Builds a specification: `Fix :Name do … end`, or `Fix do … end` for an
  # anonymous one. See {Fix.spec}.
  #
  # @param name [Symbol, nil] the name
  # @yield the document, written with {Fix::Dsl}
  # @return [Fix::Spec]
  def Fix(name = nil, &) # rubocop:disable Naming/MethodName
    ::Fix.spec(name, &)
  end
end
