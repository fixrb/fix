# frozen_string_literal: true

module Fix
  # Send log messages to the console.
  module Console
    # @param report [::Expresenter::Pass] Passed expectation result presenter.
    #
    # @see https://github.com/fixrb/expresenter
    #
    # @return [nil] Add a colored message to `$stdout`.
    def self.passed_spec(report)
      puts report.colored_string
    end

    # @param report [::Expresenter::Fail] Failed expectation result presenter.
    #
    # @see https://github.com/fixrb/expresenter
    #
    # @raise [SystemExit] Terminate execution immediately with colored message.
    def self.failed_spec(report)
      abort report.colored_string
    end
  end
end
