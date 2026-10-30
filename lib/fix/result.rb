# frozen_string_literal: true

module Fix
  # The result of an expectation: where it is written, the chain of methods
  # sent to the subject, and how it went, as Spectus says it. Plain data.
  #
  # @!attribute [r] location
  #   @return [String] `file:line`
  # @!attribute [r] chain
  #   @return [String] the methods sent to the subject, `.name(args)` each,
  #     empty for the subject itself
  # @!attribute [r] result
  #   @return [Spectus::Result]
  Result = ::Data.define(:location, :chain, :result) do
    # @return [Boolean] whether the expectation is met
    def passed?
      result.passed?
    end

    # @return [Symbol] `:success`, `:warning`, `:info`, `:failure` or `:error`
    def outcome
      result.outcome
    end

    # @return [String] what happened, as Spectus writes it
    def summary
      result.summary
    end

    # @return [String] one line: `file:line: Outcome: summary`, any line
    #   break of the summary written `\n`
    def to_s
      "#{location}: #{result}".gsub(/\R/) { "\\n" }
    end
  end
end
