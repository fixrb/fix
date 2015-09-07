module Fix
  # It's helper.
  #
  # @api private
  #
  module ItHelper
    # Add it method to the DSL.
    #
    # @api public
    #
    # @example It must eql "FOO"
    #   it { MUST Equal: 'FOO' }
    #
    # @param spec [Proc] A spec to compare against the computed actual value.
    #
    # @return [Array] List of results.
    def it(&spec)
      i = It.new do
        Sandbox.new(@front_object, *@challenges).actual
      end

      result = begin
                 i.instance_eval(&spec)
               rescue Spectus::Result::Fail => f
                 f
               end

      print result.to_char if @configuration.fetch(:verbose, true)
      results << result
    end
  end
end
