# frozen_string_literal: true

module Fix
  # Where a subject is built: an object with a method for each let, whose
  # value is computed once, the first time it is called, by running the
  # block of the let here, so that a let can call another. A new environment
  # is made for each expectation. It is an ordinary object, so that the
  # blocks of a specification can call `Kernel` and the private methods of
  # the top level, as any Ruby code does.
  #
  # @api private
  class Environment
    # @param lets [Hash{Symbol => Proc}] the lets of a context
    def initialize(lets)
      values = {}
      lets.each do |name, block|
        define_singleton_method(name) do
          values.fetch(name) { values[name] = instance_exec(&block) }
        end
      end
    end
  end

  private_constant :Environment
end
