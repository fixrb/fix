# frozen_string_literal: true

require_relative "doc"
require_relative "run"

module Fix
  # Collection of specifications.
  #
  # @api private
  class Set
    # The type of result.
    #
    # Passed expectations can be classified as:
    #
    #  * `success`
    #  * `warning`
    #  * `info`
    #
    # Failed expectations can be classified as:
    #
    #  * `failure`
    #  * `error`
    LOG_LEVELS = %w[
      none
      error
      failure
      warning
      info
      success
    ].freeze

    # @return [Array] A list of specifications.
    attr_reader :specs

    # @param name [String, Symbol] The constant name of the specifications.
    #
    # @api public
    def self.load(name)
      new(*Doc.fetch(name))
    end

    # @param contexts [Array<::Fix::Dsl>] The list of contexts document.
    def initialize(*contexts)
      @specs  = Doc.specs(*contexts)
      @passed = true
    end

    # @param subject [Proc] The block of code to be tested.
    #
    # @raise [::SystemExit] The test set failed!
    #
    # @api public
    def test(log_level: 5, &subject)
      randomize!

      specs.each do |environment, location, requirement, challenges|
        runner = Run.new(environment, requirement, *challenges)
        result = runner.against(&subject)

        failed! if result.failed?
        report!(location, result, log_level: log_level)
      end

      passed? || ::Kernel.exit(false)
    end

    private

    def randomize!
      specs.shuffle!
    end

    def failed!
      @passed = false
    end

    # @return [Boolean] The test set passed or failed.
    def passed?
      @passed
    end

    def report!(path, result, log_level:)
      return unless report?(result, log_level: log_level)

      puts "#{path} #{result.colored_string}"
    end

    def report?(result, log_level:)
      LOG_LEVELS[1..log_level].any? { |name| result.public_send("#{name}?") }
    end
  end
end
