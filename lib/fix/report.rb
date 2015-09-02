module Fix
  # The class that is responsible for reporting the result of the test.
  #
  # @api private
  #
  class Report
    # Initialize the report class.
    #
    # @param test [Test] The test.
    def initialize(test)
      @test = test
    end

    # @!attribute [r] test
    #
    # @return [Test] The result.
    attr_reader :test

    # The report in plain text.
    #
    # @return [String] The report in plain text.
    def to_s
      "\n"                              \
      "\n"                              \
      "#{results_banner.join("\n")}\n"  \
      "#{total_time_banner}\n"          \
      "#{statistics_banner}\n"
    end

    private

    # @private
    def total_time_banner
      "Ran #{test.results.length} tests in #{test.total_time} seconds"
    end

    # @private
    def results_banner
      test.results.reject { |r| r.to_char == '.' }.map.with_index(1) do |r, i|
        "#{i}. #{r.message}\n" + maybe_backtrace(r)
      end
    end

    # @private
    def maybe_backtrace(result)
      if result.respond_to?(:backtrace)
        "    #{result.backtrace.first}\n"
      else
        ''
      end
    end

    # @private
    def statistics_banner
      "#{test.statistics.fetch(:pass_percent)}% compliant - " \
      "#{test.statistics.fetch(:total_infos)} infos, "        \
      "#{test.statistics.fetch(:total_failures)} failures, "  \
      "#{test.statistics.fetch(:total_errors)} errors"
    end
  end
end
