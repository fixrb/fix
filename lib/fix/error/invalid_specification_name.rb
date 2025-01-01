# frozen_string_literal: true

module Fix
  module Error
    # Error raised when an invalid specification name is provided during declaration
    class InvalidSpecificationName < ::NameError
      def initialize(name)
        super("Invalid specification name '#{name}'. Specification names must be valid Ruby constants.")
      end
    end
  end
end
