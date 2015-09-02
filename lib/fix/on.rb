require 'spectus/challenge'
require 'spectus/result/fail'

require_relative 'it'

%w(it on).each do |helper|
  require_relative File.join 'helpers', "#{helper}_helper"
end

require_relative 'sandbox'

module Fix
  # Wraps the target of challenge.
  #
  # @api private
  #
  class On
    # Initialize the on class.
    #
    # @param front_object [BasicObject] The front object of the test.
    # @param results      [Array]       The list of collected results.
    # @param challenges   [Array]       The list of challenges to apply.
    def initialize(front_object, results, *challenges)
      @front_object = front_object
      @results      = results
      @challenges   = challenges
    end

    # @!attribute [r] results
    #
    # @return [Array] The results.
    attr_reader :results

    [ItHelper, OnHelper].each { |helper| include helper }
  end
end
