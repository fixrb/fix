# frozen_string_literal: true

module Fix
  module Error
    # Error raised when a specification cannot be found at runtime
    class SpecificationNotFound < ::NameError
      def initialize(name)
        super("Specification '#{name}' not found. Make sure it's defined before running the test.")
      end
    end
  end
end
