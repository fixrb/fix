# frozen_string_literal: true

# Namespace for the Fix framework.
#
# @api public
#
module Fix
  # Specs are built with this method.
  #
  # @example 42 must be equal to 42
  #   describe(42) do
  #     it { MUST equal 42 }
  #   end
  #
  # @param front_object [BasicObject] The front object.
  # @param options      [Hash]        Some options.
  # @param specs        [Proc]        The set of specs.
  #
  # @raise [SystemExit] The result of the test.
  def self.describe(front_object, options = {}, &specs)
    t = Test.new(front_object, options, &specs)

    print t.report.to_s if options.fetch(:verbose, true)
    exit t.pass?
  end
end

require_relative File.join 'fix', 'test'
