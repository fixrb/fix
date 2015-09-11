require 'defi'
require 'spectus/result/fail'

require_relative 'it'

%w(it on).each do |helper|
  require_relative File.join 'helpers', "#{helper}_helper"
end

module Fix
  # Wraps the target of challenge.
  #
  # @api private
  #
  class On
    # Initialize the on class.
    #
    # @param front_object   [BasicObject] The front object of the test.
    # @param results        [Array]       The list of collected results.
    # @param challenges     [Array]       The list of challenges to apply.
    # @param configuration  [Hash]        Settings.
    def initialize(front_object, results, challenges, configuration = {})
      @front_object   = front_object
      @results        = results
      @challenges     = challenges
      @configuration  = configuration
    end

    # @!attribute [r] results
    #
    # @return [Array] The results.
    attr_reader :results

    [ItHelper, OnHelper].each { |helper| include helper }
  end
end
