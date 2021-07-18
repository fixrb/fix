# frozen_string_literal: true

require "expresenter/fail"

require_relative "console"
require_relative "doc"

module Fix
  # Module for testing spec documents.
  class Test
    attr_reader :contexts

    def initialize(*contexts)
      @contexts = contexts
    end

    def test(&block)
      requirements(&block)
      exit(true)
    end

    private

    def requirements(&block)
      contexts.flat_map do |context|
        sandbox = context.new
        sandbox.public_methods(false).shuffle.map do |public_method|
          definition = sandbox.public_send(public_method)

          report = begin
            definition.call do
              front_object = instance_eval(&block)

              context.send(:challenges).inject(front_object) do |object, challenge|
                challenge.to(object).call
              end
            end
          rescue ::Expresenter::Fail => e
            e
          end

          if report.passed?
            Console.passed_spec report
          else
            Console.failed_spec report
          end
        end
      end
    end
  end
end
