# frozen_string_literal: true

module Fix
  # A context of a specification, with everything needed to run its
  # expectations: the lets in force, the chain of methods to send to the
  # subject, and the expectations written in it.
  #
  # @!attribute [r] lets
  #   @return [Hash{Symbol => Proc}] the lets, frozen
  # @!attribute [r] challenges
  #   @return [Array<Defi::Challenge>] the chain of the `on` above, frozen
  # @!attribute [r] chain
  #   @return [String] its text, as `.name(args)` each, empty at the root
  # @!attribute [r] expectations
  #   @return [Array<Fix::Expectation>] in the order written
  #
  # @api private
  Node = ::Data.define(:lets, :challenges, :chain, :expectations)

  # An expectation: a requirement at a line of the specification.
  #
  # @!attribute [r] location
  #   @return [String] `file:line`
  # @!attribute [r] requirement
  #   @return [Spectus::Requirement]
  #
  # @api private
  Expectation = ::Data.define(:location, :requirement)

  private_constant :Node
  private_constant :Expectation
end
