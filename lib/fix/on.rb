require 'aw'
require 'defi'

module Fix
  # Wraps the target of challenge.
  #
  # @api private
  #
  class On
    # Initialize the on class.
    #
    # @param described      [#object_id]  The front object of the test.
    # @param results        [Array]       The list of collected results.
    # @param challenges     [Array]       The list of challenges to apply.
    # @param helpers        [Hash]        The list of helpers.
    # @param configuration  [Hash]        Settings.
    def initialize(described, results, challenges, helpers, configuration)
      @described      = described
      @results        = results
      @challenges     = challenges
      @helpers        = helpers
      @configuration  = configuration
    end

    # @!attribute [r] described
    #
    # @return [#object_id] The front object of the test.
    attr_reader :described

    # @!attribute [r] results
    #
    # @return [Array] The list of collected results.
    attr_reader :results

    # @!attribute [r] challenges
    #
    # @return [Array] The list of challenges to apply.
    attr_reader :challenges

    # @!attribute [r] helpers
    #
    # @return [Hash] The list of helpers.
    attr_reader :helpers

    # @!attribute [r] configuration
    #
    # @return [Hash] Settings.
    attr_reader :configuration

    # Add it method to the DSL.
    #
    # @api public
    #
    # @example It must eql "FOO"
    #   it { MUST equal 'FOO' }
    #
    # @param spec [Proc] A spec to compare against the computed actual value.
    #
    # @return [Array] List of results.
    def it(*, &spec)
      i = It.new(described, challenges, helpers.dup)

      result = i.verify(&spec)

      if configuration.fetch(:verbose, true)
        print result.to_char(configuration.fetch(:color, false))
      end

      results << result
    end

    # Add on method to the DSL.
    #
    # @api public
    #
    # @example On +2, it must equal 44.
    #   on(:+, 2) do
    #     it { MUST equal 44 }
    #   end
    #
    # @param method_name [Symbol] The identifier of a method.
    # @param args        [Array]  A list of arguments.
    # @param block       [Proc]   A spec to compare against the computed value.
    #
    # @return [Array] List of results.
    def on(method_name, *args, &block)
      o = On.new(described,
                 results,
                 (challenges + [Defi.send(method_name, *args)]),
                 helpers.dup,
                 configuration)

      o.instance_eval(&block)
    end

    # Add context method to the DSL, to build an isolated scope.
    #
    # @api public
    #
    # @example Context when logged in.
    #   context 'when logged in' do
    #     it { MUST equal 200 }
    #   end
    #
    # @param block [Proc] A block of specs to test in isolation.
    #
    # @return [Array] List of results.
    def context(*, &block)
      o = On.new(described,
                 [],
                 challenges,
                 helpers.dup,
                 configuration)

      results.concat Aw.fork! { o.instance_eval(&block) }
    end

    # @api public
    #
    # @example Let's define the answer to the Ultimate Question of Life, the
    #   Universe, and Everything.
    #
    #   let(:answer) { 42 }
    #
    # @param method_name [Symbol] The identifier of a method.
    # @param block       [Proc]   A spec to compare against the computed value.
    #
    # @return [#object_id] List of results.
    def let(method_name, &block)
      helpers.update(method_name => block)
    end
  end
end

require_relative 'it'
