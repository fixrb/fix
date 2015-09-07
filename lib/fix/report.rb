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
      maybe_results_banner + total_time_banner + statistics_banner
    end

    private

    # @private
    def total_time_banner
      "Ran #{test.results.length} tests in #{test.total_time} seconds\n"
    end

    # @private
    def alerts
      test.results.reject { |r| r.to_char == '.' }
    end

    # @private
    def maybe_results_banner
      if alerts.any?
        "\n" \
        "\n" \
        "#{results_banner.join("\n")}\n"
      else
        ''
      end
    end

    # @private
    def results_banner
      alerts.map.with_index(1) do |r, i|
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
      "#{test.statistics.fetch(:total_errors)} errors\n"
    end
  end
end
