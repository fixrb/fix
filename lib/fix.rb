require_relative File.join 'fix', 'test'

# Namespace for the Fix framework.
#
# @api public
#
module Fix
  # Specs are built with this method.
  #
  # @example 42 must be equal to 42
  #   describe(42) do
  #     it { MUST Equal: 42 }
  #   end
  #
  # @param front_object [BasicObject] The front object.
  # @param specs        [Proc]        The set of specs.
  #
  # @return [ExpectationTarget] The expectation target.
  def self.describe(front_object, &specs)
    t = Test.new(front_object, &specs)

    puts "#{t.report}"
    exit t.pass?
  end
end
