# frozen_string_literal: true

require "expresenter/fail"

require_relative "console"
require_relative "doc"

module Fix
  # Module for testing spec documents.
  class Test
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def call(subject)
      Console.title(name, subject)
      requirements(subject).each { |requirement| test(requirement) }
      exit(true)
    end

    private

    def requirements(subject)
      specs.flat_map do |spec|
        example = spec.new(subject)
        example.public_methods(false).map do |public_method|
          example.method(public_method)
        end
      end.shuffle
    end

    def specs
      Doc.const_get(name).const_get(:SPECS)
    end

    def test(requirement)
      Console.passed_spec requirement.call
    rescue ::Expresenter::Fail => e
      Console.failed_spec e
    end
  end
end
