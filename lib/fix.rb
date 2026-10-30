# frozen_string_literal: true

require_relative "fix/spec"
require_relative "kernel"

# Specifications with the MUST, SHOULD and MAY of RFC 2119. A specification
# says what a value must, should or may do, in a document free of logic;
# any subject is then tested against it, each context in a process of its
# own.
#
# @example
#   Fix :Duck do
#     on(:swims) { it MUST eq "Swoosh..." }
#     on(:sings) { it MAY eq "♪... ♫..." }
#   end
#
#   Fix[:Duck].test { Duck.new } # => true
module Fix
  @specs = {}.freeze

  # Builds a specification, and registers it under its name once it is
  # built: a block that raises registers nothing.
  #
  # @param name [Symbol, nil] the name, or nil for an anonymous specification
  # @yield the document, written with {Fix::Dsl}
  # @return [Fix::Spec]
  # @raise [ArgumentError] without a block, with a name that is not a Symbol
  #   or that is already registered, or for a mistake in a word of the
  #   document
  # @raise [NameError] for a let named in an expectation
  # @raise [KeyError] for a `fix(:Name)` not registered yet
  def self.spec(name = nil, &block)
    raise ::ArgumentError, "a block must be given" unless block
    raise ::ArgumentError, "the name must be a Symbol" unless name.nil? || ::Symbol === name

    spec = Spec.new(name:, nodes: Dsl.build(&block))
    return spec if name.nil?
    raise ::ArgumentError, "#{name.inspect} is already a specification" if @specs.key?(name)

    @specs = @specs.merge(name => spec).freeze
    spec
  end

  # @param name [Symbol] the name of a registered specification
  # @return [Fix::Spec]
  # @raise [KeyError] when no specification has that name
  def self.[](name)
    @specs.fetch(name) do
      raise ::KeyError.new("no specification named #{name.inspect}", receiver: @specs, key: name)
    end
  end
end
