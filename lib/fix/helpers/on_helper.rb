module Fix
  # On's helper.
  #
  # @api private
  #
  module OnHelper
    # Add on method to the DSL.
    #
    # @api public
    #
    # @example On +2, it must equal 44.
    #   on(:+, 2) do
    #     it { MUST Equal: 44 }
    #   end
    #
    # @param method_name [Symbol] The identifier of a method.
    # @param args        [Array]  A list of arguments.
    # @param block       [Proc]   A spec to compare against the computed value.
    #
    # @return [Array] List of results.
    def on(method_name, *args, &block)
      o = On.new(@front_object,
                 results,
                 (@challenges + [Defi.send(method_name, *args)]),
                 @helpers.dup,
                 @configuration)

      o.instance_eval(&block)
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
    # @return [BasicObject] List of results.
    def let(method_name, &block)
      @helpers.update(method_name => block)
    end
  end
end
