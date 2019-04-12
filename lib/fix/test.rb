# frozen_string_literal: true

module Fix
  # Wraps the target of the specs document.
  #
  # @api private
  #
  class Test
    # Initialize the test class.
    #
    # @param front_object [BasicObject] The front object of the test.
    # @param options      [Hash]        Some options.
    # @param specs        [Proc]        The specs to test against the object.
    def initialize(front_object, verbose: true, color: true, **options, &specs)
      @configuration = options.merge(
        verbose: verbose,
        color: color
      )

      start_time = Time.now

      g = On.new(front_object, [], [], {}, @configuration)
      g.instance_eval(&specs)

      @results    = g.results
      @total_time = Time.now - start_time
    end

    # @!attribute [r] configuration
    #
    # @return [Hash] The settings.
    attr_reader :configuration

    # @!attribute [r] results
    #
    # @return [Array] The results.
    attr_reader :results

    # @!attribute [r] total_time
    #
    # @return [Float] The total time.
    attr_reader :total_time

    # Some statistics.
    #
    # @return [Hash] Some statistics.
    def statistics
      {
        pass_percent: pass_percent,
        total_infos: results.count { |r| r.to_sym.equal?(:info) },
        total_failures: results.count { |r| r.to_sym.equal?(:failure) },
        total_errors: results.count { |r| r.to_sym.equal?(:error) }
      }
    end

    # The report of the test.
    #
    # @return [Report] The report of the test.
    def report
      Report.new(self)
    end

    # The state of the test.
    #
    # @return [Boolean] Return true if the test pass.
    def pass?
      results.all?(&:result?)
    end

    # @return [Boolean] Return false if the test fail.
    def fail?
      !pass?
    end

    private

    # @private
    #
    # @return [Fixnum] Return the percentage of passing specs.
    def pass_percent
      return 100 if results.empty?

      (results.count(&:result?) / results.length.to_f * 100).round
    end
  end
end

require_relative 'on'
require_relative 'report'
