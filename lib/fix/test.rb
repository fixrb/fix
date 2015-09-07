require_relative 'on'
require_relative 'report'

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
    def initialize(front_object, options = {}, &specs)
      configuration = { verbose: true }
      configuration.update(options)

      start_time = Time.now

      g = On.new(front_object, [], [], configuration)
      g.instance_eval(&specs)

      @results    = g.results
      @total_time = Time.now - start_time
    end

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
        pass_percent:   pass_percent,
        total_infos:    results.count { |r| r.to_char == 'I' },
        total_failures: results.count { |r| r.to_char == 'F' },
        total_errors:   results.count { |r| r.to_char == 'E' }
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
      if results.empty?
        100
      else
        (results.count(&:result?) / results.length.to_f * 100).round
      end
    end
  end
end
