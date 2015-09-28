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
    # @return [Test] The results of the test.
    attr_reader :test

    # The report in plain text.
    #
    # @return [String] The report in plain text.
    def to_s
      maybe_thematic_break + maybe_alerts + total_time + statistics
    end

    private

    # @private
    def maybe_thematic_break
      test.results.any? && @test.configuration.fetch(:verbose) ? "\n\n" : ''
    end

    # @private
    def total_time
      "Ran #{test.results.length} tests in #{test.total_time} seconds\n"
    end

    # @private
    def alerts
      test.results.reject { |r| r.to_sym.equal?(:success) }
    end

    # @private
    def maybe_alerts
      alerts.any? ? "#{results.join("\n")}\n" : ''
    end

    # @private
    def results
      alerts.map.with_index(1) do |r, i|
        maybe_results_color("#{i}. #{r.message}\n" + maybe_backtrace(r), r)
      end
    end

    # @private
    def maybe_results_color(string, result)
      return string unless @test.configuration.fetch(:color)

      color = send("#{result.to_sym}_color")
      "\e[#{color}m#{string}\e[0m"
    end

    # @private
    def maybe_backtrace(result)
      result.respond_to?(:backtrace) ? "    #{result.backtrace.first}\n" : ''
    end

    # @private
    def statistics
      if @test.configuration.fetch(:color)
        statistics_color(statistics_text, test.statistics)
      else
        statistics_text
      end
    end

    # @private
    def statistics_text
      "#{test.statistics.fetch(:pass_percent)}% compliant - " \
      "#{test.statistics.fetch(:total_infos)} infos, "        \
      "#{test.statistics.fetch(:total_failures)} failures, "  \
      "#{test.statistics.fetch(:total_errors)} errors\n"
    end

    # @private
    def statistics_color(string, stats)
      if stats.fetch(:total_errors) > 0
        "\e[#{error_color}m#{string}\e[0m"
      elsif stats.fetch(:total_failures) > 0
        "\e[#{failure_color}m#{string}\e[0m"
      elsif stats.fetch(:total_infos) > 0
        "\e[#{info_color}m#{string}\e[0m"
      else
        "\e[#{success_color}m#{string}\e[0m"
      end
    end

    # @private
    def error_color
      31
    end

    # @private
    def failure_color
      35
    end

    # @private
    def info_color
      33
    end

    # @private
    def success_color
      32
    end
  end
end
