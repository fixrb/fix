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
      maybe_thematic_break +
        maybe_alerts_banner +
        total_time_banner +
        statistics_banner
    end

    private

    # @private
    def maybe_thematic_break
      test.results.any? && @test.configuration.fetch(:verbose) ? "\n\n" : ''
    end

    # @private
    def total_time_banner
      "Ran #{test.results.length} tests in #{test.total_time} seconds\n"
    end

    # @private
    def alerts
      test.results.reject { |r| r.to_sym.equal?(:success) }
    end

    # @private
    def maybe_alerts_banner
      alerts.any? ? "#{results_banner.join("\n")}\n" : ''
    end

    # @private
    def results_banner
      alerts.map.with_index(1) do |r, i|
        s = "#{i}. #{r.message}\n" + maybe_backtrace(r)

        next s unless @test.configuration.fetch(:color)

        if r.to_sym.equal?(:info)
          "\e[33m#{s}\e[0m"
        elsif r.to_sym.equal?(:failure)
          "\e[35m#{s}\e[0m"
        else
          "\e[31m#{s}\e[0m"
        end
      end
    end

    # @private
    def maybe_backtrace(result)
      result.respond_to?(:backtrace) ? "    #{result.backtrace.first}\n" : ''
    end

    # @private
    def statistics_banner
      s = "#{test.statistics.fetch(:pass_percent)}% compliant - " \
          "#{test.statistics.fetch(:total_infos)} infos, "        \
          "#{test.statistics.fetch(:total_failures)} failures, "  \
          "#{test.statistics.fetch(:total_errors)} errors\n"

      return s unless @test.configuration.fetch(:color)

      stats = test.statistics

      if stats.fetch(:total_errors) > 0
        "\e[31m#{s}\e[0m"
      elsif stats.fetch(:total_failures) > 0
        "\e[35m#{s}\e[0m"
      elsif stats.fetch(:total_infos) > 0
        "\e[33m#{s}\e[0m"
      else
        "\e[32m#{s}\e[0m"
      end
    end
  end
end
